# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

class TestData
  class_attribute :bank_value
  class_attribute :bank2_value
  class_attribute :profit

  class_attribute :t_share2_to_bank
  class_attribute :t_share_to_bank
  class_attribute :t_bank_to_forex
  class_attribute :t_bank_to_forex3
  class_attribute :t_bank_to_purchase
  class_attribute :t_forex2_to_bank
  class_attribute :t_forex4_to_bank
  class_attribute :t2_forex4_to_bank
  class_attribute :t_bank_to_office
end

describe Txn do
  before(:all) do
    DatabaseCleaner.start
    @rub = Factory(:chart).currency
    @eur = Factory(:money)
    @aasii = Factory(:asset)
    @share2 = Factory(:deal, :give => @aasii, :take => @rub, :rate => 10000.0)
    @share1 = Factory(:deal, :give => @aasii, :take => @rub, :rate => 10000.0)
    @bank = Factory(:deal, :give => @rub, :take => @rub, :rate => 1.0)
    @purchase = Factory(:deal, :give => @rub, :rate => 0.0000142857143)
    @bank2 = Factory(:deal, :give => @eur, :take => @eur, :rate => 1.0)
    @forex1 = Factory(:deal, :give => @rub, :take => @eur, :rate => 0.028612303)
    @forex2 = Factory(:deal, :give => @eur, :take => @rub, :rate => 35.0)
    @forex3 = Factory(:deal, :rate => (1 / 34.2), :give => @bank.give, :take => @bank2.take)
    @forex4 = Factory(:deal, :rate => 34.95, :give => @bank2.give, :take => @bank.give)
    @office = Factory(:deal, :rate => (1 / 2000.0), :give => @bank.give, :take => Factory(:asset))
  end

  after(:all) do
    DatabaseCleaner.clean
  end

  it "should create states" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 22, 12, 0, 0), :from => @share2,
                   :to => @bank, :resource => @rub, :amount => 100000.0)
    @share2.state(fact.day).resource.should eq(@aasii)
    @share2.state(fact.day).amount.should eq(10.0)
    @share2.state(fact.day).side.should eq(State::PASSIVE)
    @bank.state(fact.day).resource.should eq(@rub)
    @bank.state(fact.day).amount.should eq(100000.0)
    @bank.state(fact.day).side.should eq(State::ACTIVE)
    State.all.count.should eq(2)
  end

  it "should update states" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 22, 12, 0, 0), :from => @share1,
                 :to => @bank, :resource => @rub, :amount => 142000.0)
    @share2.state(fact.day).resource.should eq(@aasii)
    @share2.state(fact.day).amount.should eq(10.0)
    @share2.state(fact.day).side.should eq(State::PASSIVE)
    @share1.state(fact.day).resource.should eq(@aasii)
    @share1.state(fact.day).amount.should eq(14.2)
    @share1.state(fact.day).side.should eq(State::PASSIVE)
    @bank.state(fact.day).resource.should eq(@rub)
    @bank.state(fact.day).amount.should eq(242000.0)
    @bank.state(fact.day).side.should eq(State::ACTIVE)
    State.all.count.should eq(3)
  end

  it "should replace states" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => @bank,
                   :to => @purchase, :resource => @rub, :amount => 70000.0)
    @share2.state(fact.day).resource.should eq(@aasii)
    @share2.state(fact.day).amount.should eq(10.0)
    @share2.state(fact.day).side.should eq(State::PASSIVE)
    @share1.state(fact.day).resource.should eq(@aasii)
    @share1.state(fact.day).amount.should eq(14.2)
    @share1.state(fact.day).side.should eq(State::PASSIVE)
    @bank.state(fact.day).resource.should eq(@rub)
    @bank.state(fact.day).amount.should eq(172000.0)
    @bank.state(fact.day).side.should eq(State::ACTIVE)
    @purchase.state(fact.day).resource.should eq(@purchase.take)
    @purchase.state(fact.day).amount.should eq(1.0)
    @purchase.state(fact.day).side.should eq(State::ACTIVE)
    @bank.states.first.resource.should eq(@rub)
    @bank.states.first.amount.should eq(242000.0)
    @bank.states.first.side.should eq(State::ACTIVE)
    @bank.states.first.paid.to_s.should eq(fact.day.to_s)
    State.all.count.should eq(5)
  end

  it "should delete states" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => @forex1,
                   :to => @bank2, :resource => @eur, :amount => 1000.0)
    @share2.state(fact.day).resource.should eq(@aasii)
    @share2.state(fact.day).amount.should eq(10.0)
    @share2.state(fact.day).side.should eq(State::PASSIVE)
    @share1.state(fact.day).resource.should eq(@aasii)
    @share1.state(fact.day).amount.should eq(14.2)
    @share1.state(fact.day).side.should eq(State::PASSIVE)
    @bank.state(fact.day).resource.should eq(@rub)
    @bank.state(fact.day).amount.should eq(172000.0)
    @bank.state(fact.day).side.should eq(State::ACTIVE)
    @purchase.state(fact.day).resource.should eq(@purchase.take)
    @purchase.state(fact.day).amount.should eq(1.0)
    @purchase.state(fact.day).side.should eq(State::ACTIVE)
    @bank2.state(fact.day).resource.should eq(@eur)
    @bank2.state(fact.day).amount.should eq(1000.0)
    @bank2.state(fact.day).side.should eq(State::ACTIVE)
    @forex1.state(fact.day).resource.should eq(@rub)
    @forex1.state(fact.day).amount.should eq(34950.0)
    @forex1.state(fact.day).side.should eq(State::PASSIVE)
    State.all.count.should eq(7)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => @bank,
                   :to => @forex1, :resource => @rub, :amount => 34950.0)
    @share2.state(fact.day).resource.should eq(@aasii)
    @share2.state(fact.day).amount.should eq(10.0)
    @share2.state(fact.day).side.should eq(State::PASSIVE)
    @share1.state(fact.day).resource.should eq(@aasii)
    @share1.state(fact.day).amount.should eq(14.2)
    @share1.state(fact.day).side.should eq(State::PASSIVE)
    @bank.state(fact.day).resource.should eq(@rub)
    @bank.state(fact.day).amount.should eq(137050.0)
    @bank.state(fact.day).side.should eq(State::ACTIVE)
    @purchase.state(fact.day).resource.should eq(@purchase.take)
    @purchase.state(fact.day).amount.should eq(1.0)
    @purchase.state(fact.day).side.should eq(State::ACTIVE)
    @bank2.state(fact.day).resource.should eq(@eur)
    @bank2.state(fact.day).amount.should eq(1000.0)
    @bank2.state(fact.day).side.should eq(State::ACTIVE)
    @forex1.state.should be_nil
    State.all.count.should eq(6)
  end

  it "should close state" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => @bank2,
                   :to => @forex2, :resource => @eur, :amount => 1000.0)
    @share2.state(fact.day).resource.should eq(@aasii)
    @share2.state(fact.day).amount.should eq(10.0)
    @share2.state(fact.day).side.should eq(State::PASSIVE)
    @share1.state(fact.day).resource.should eq(@aasii)
    @share1.state(fact.day).amount.should eq(14.2)
    @share1.state(fact.day).side.should eq(State::PASSIVE)
    @bank.state(fact.day).resource.should eq(@rub)
    @bank.state(fact.day).amount.should eq(137050.0)
    @bank.state(fact.day).side.should eq(State::ACTIVE)
    @purchase.state(fact.day).resource.should eq(@purchase.take)
    @purchase.state(fact.day).amount.should eq(1.0)
    @purchase.state(fact.day).side.should eq(State::ACTIVE)
    @bank2.state.should be_nil
    @forex1.state.should be_nil
    @forex2.state(fact.day).resource.should eq(@rub)
    @forex2.state(fact.day).amount.should eq(35000.0)
    @forex2.state(fact.day).side.should eq(State::ACTIVE)
    State.all.count.should eq(6)
  end

  it "should create balances" do
    Fact.pendings.should_not be_nil
    Fact.pendings.count.should eq(6)
    p_fact = Fact.pendings.first
    TestData.t_share2_to_bank = Txn.create!(:fact => p_fact)
    TestData.t_share2_to_bank.value.should eq(p_fact.amount)
    @share2.balance.should_not be_nil
    @share2.balance.resource.should eq(p_fact.from.give)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(p_fact.amount / @share2.rate)
    @share2.balance.value.should eq(p_fact.amount)
    @bank.balance.should_not be_nil
    @bank.balance.resource.should eq(p_fact.to.take)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @bank.balance.amount.should eq(p_fact.amount)
    @bank.balance.value.should eq(p_fact.amount)
  end

  it "should have next behaviour" do
    should validate_presence_of :value
    should validate_presence_of :fact_id
    should validate_presence_of :status
    should validate_uniqueness_of :fact_id
    should belong_to :fact
    should have_many Txn.versions_association_name
  end

  it "should update balances" do
    Fact.pendings.count.should eq(5)
    p_fact = Fact.pendings.first
    TestData.t_share_to_bank = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(3)
    TestData.t_share_to_bank.value.should eq(p_fact.amount)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(100000.0 / @share2.rate)
    @share2.balance.value.should eq(100000.0)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @bank.balance.amount.should eq(100000.0 + 142000.0)
    @bank.balance.value.should eq(100000.0 + 142000.0)
    @share1.balance.side.should eq(Balance::PASSIVE)
    @share1.balance.amount.should eq(142000.0 / @share1.rate)
    @share1.balance.value.should eq(142000.0)
  end

  it "should replace balances" do
    Fact.pendings.count.should eq(4)
    p_fact = Fact.pendings.first
    TestData.t_bank_to_purchase = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(4)
    TestData.t_bank_to_purchase.value.should eq(p_fact.amount)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(100000.0 / @share2.rate)
    @share2.balance.value.should eq(100000.0)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0)
    @bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0)
    @share1.balance.side.should eq(Balance::PASSIVE)
    @share1.balance.amount.should eq(142000.0 / @share1.rate)
    @share1.balance.value.should eq(142000.0)
    @purchase.balance.side.should eq(Balance::ACTIVE)
    @purchase.balance.amount.should eq(1.0)
    @purchase.balance.value.should eq(70000.0)
    @bank.balances.where("balances.paid IS NOT NULL").count.should eq(1)
    b = @bank.balances.where("balances.paid IS NOT NULL").first
    b.side.should eq(Balance::ACTIVE)
    b.amount.should eq(100000.0 + 142000.0)
    b.value.should eq(100000.0 + 142000.0)
  end

  it "should delete balances" do
    Fact.pendings.count.should eq(3)
    p_fact = Fact.pendings.first
    t = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(6)
    t.value.should eq((1000.0 / @forex1.rate).accounting_norm)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(100000.0 / @share2.rate)
    @share2.balance.value.should eq(100000.0)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0)
    @bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0)
    @share1.balance.side.should eq(Balance::PASSIVE)
    @share1.balance.amount.should eq(142000.0 / @share1.rate)
    @share1.balance.value.should eq(142000.0)
    @purchase.balance.side.should eq(Balance::ACTIVE)
    @purchase.balance.amount.should eq(1.0)
    @purchase.balance.value.should eq(70000.0)
    @forex1.balance.side.should eq(Balance::PASSIVE)
    @forex1.balance.amount.should eq((1000.0 / @forex1.rate).accounting_norm)
    @forex1.balance.value.should eq((1000.0 / @forex1.rate).accounting_norm)
    @bank2.balance.side.should eq(Balance::ACTIVE)
    @bank2.balance.amount.should eq(1000.0)
    @bank2.balance.value.should eq((1000.0 / @forex1.rate).accounting_norm)

    Fact.pendings.count.should eq(2)
    p_fact = Fact.pendings.first
    TestData.t_bank_to_forex = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(5)
    TestData.t_bank_to_forex.value.should eq((1000.0 / @forex1.rate).accounting_norm)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(100000.0 / @share2.rate)
    @share2.balance.value.should eq(100000.0)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0 -
                                (1000.0 / @forex1.rate).accounting_norm)
    @bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0 -
                               (1000.0 / @forex1.rate).accounting_norm)
    @share1.balance.side.should eq(Balance::PASSIVE)
    @share1.balance.amount.should eq(142000.0 / @share1.rate)
    @share1.balance.value.should eq(142000.0)
    @purchase.balance.side.should eq(Balance::ACTIVE)
    @purchase.balance.amount.should eq(1.0)
    @purchase.balance.value.should eq(70000.0)
    @forex1.balance.should be_nil
    @bank2.balance.side.should eq(Balance::ACTIVE)
    @bank2.balance.amount.should eq(1000.0)
    @bank2.balance.value.should eq((1000.0 / @forex1.rate).accounting_norm)
  end

  it "should close balances" do
    Fact.pendings.count.should eq(1)
    p_fact = Fact.pendings.first
    Txn.create!(:fact => p_fact)
    fact = Fact.find(p_fact.id)
    fact.txn.value.should eq((1000.0 / @forex1.rate).accounting_norm)
    fact.txn.status.should eq(1)
    fact.txn.earnings.should eq((1000.0 * (@forex2.rate -
                                (1/@forex1.rate))).accounting_norm)
    Balance.open.count.should eq(5)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(100000.0 / @share2.rate)
    @share2.balance.value.should eq(100000.0)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0 -
                                (1000.0 / @forex1.rate).accounting_norm)
    @bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0 -
                               (1000.0 / @forex1.rate).accounting_norm)
    @share1.balance.side.should eq(Balance::PASSIVE)
    @share1.balance.amount.should eq(142000.0 / @share1.rate)
    @share1.balance.value.should eq(142000.0)
    @purchase.balance.side.should eq(Balance::ACTIVE)
    @purchase.balance.amount.should eq(1.0)
    @purchase.balance.value.should eq(70000.0)
    @forex1.balance.should be_nil
    @bank2.balance.should be_nil
    @forex2.balance.side.should eq(Balance::ACTIVE)
    @forex2.balance.amount.should eq(1000.0 * @forex2.rate)
    @forex2.balance.value.should eq(1000.0 * @forex2.rate)
    Income.open.count.should eq(1)
    TestData.profit = (1000.0 * (@forex2.rate - (1/@forex1.rate))).accounting_norm
    Income.open.first.value.should eq(TestData.profit)
    Fact.pendings.should be_empty
  end

  it "should process loss transaction" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                                      :from => @forex2,
                                                      :to => @bank,
                                                      :resource => @forex2.take,
                                                      :amount => 1000.0 * @forex2.rate)
    TestData.t_forex2_to_bank = Factory(:txn, :fact => fact)
    Balance.open.count.should eq(4)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(100000.0 / @share2.rate)
    @share2.balance.value.should eq(100000.0)
    @share1.balance.side.should eq(Balance::PASSIVE)
    @share1.balance.amount.should eq(142000.0 / @share1.rate)
    @share1.balance.value.should eq(142000.0)
    @purchase.balance.side.should eq(Balance::ACTIVE)
    @purchase.balance.amount.should eq(1.0)
    @purchase.balance.value.should eq(70000.0)
    @bank.balance.side.should eq(Balance::ACTIVE)
    TestData.bank_value = 100000.0 + 142000.0 - 70000.0 + (1000.0 * (@forex2.rate - (1 / @forex1.rate))).accounting_norm
    @bank.balance.amount.should eq(TestData.bank_value)
    @bank.balance.value.should eq(TestData.bank_value)
    @forex1.balance.should be_nil
    @bank2.balance.should be_nil
    @forex2.balance.should be_nil

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                          :amount => (5000.0 / @forex3.rate).accounting_norm,
                                          :from => @bank, :to => @forex3,
                                          :resource => @forex3.give)
    TestData.t_bank_to_forex3 = Factory(:txn, :fact => fact)
    Balance.open.count.should eq(5)
    @bank.balance.side.should eq(Balance::ACTIVE)
    TestData.bank_value -= (5000.0 / @forex3.rate).accounting_norm
    @bank.balance.amount.should eq(TestData.bank_value)
    @bank.balance.value.should eq(TestData.bank_value)
    @forex3.balance.side.should eq(Balance::ACTIVE)
    @forex3.balance.amount.should eq(5000.0)
    @forex3.balance.value.should eq((5000.0 / @forex3.rate).accounting_norm)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :amount => 5000.0,
                                          :from => @forex3, :to => @bank2,
                                          :resource => @forex3.take)
    Factory(:txn, :fact => fact)
    Balance.open.count.should eq(5)
    @bank2.balance.side.should eq(Balance::ACTIVE)
    @bank2.balance.amount.should eq(5000.0)
    @bank2.balance.value.should eq((5000.0 / @forex3.rate).accounting_norm)
    @forex3.balance.should be_nil

    f = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => @office,
                :to => Deal.income, :resource => @office.take)
    State.open.count.should eq(6)
    @office.state.amount.should eq((1 / @office.rate).accounting_norm)
    @office.state.resource.should eq(@bank.give)
    @bank.state.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.state.resource.should eq(@bank.give)
    t = Txn.create!(:fact => f)
    Balance.open.count.should eq(6)
    t.to_balance.should be_nil
    @office.balance.amount.should eq((1 / @office.rate).accounting_norm)
    @office.balance.value.should eq((1 / @office.rate).accounting_norm)
    @office.balance.side.should eq(Balance::PASSIVE)
    Income.open.count.should eq(1)
    TestData.profit -= (1 / @office.rate).accounting_norm
    Income.open.first.value.should eq(TestData.profit)
  end

  it "should process split transaction" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => 2000.0, :from => @bank2, :to => @forex4,
                                       :resource => @forex4.give)
    t = Factory(:txn, :fact => fact)
    Balance.open.count.should eq(7)
    TestData.bank2_value = 5000.0 - t.fact.amount
    @bank2.balance.amount.should eq(TestData.bank2_value)
    @bank2.balance.value.should eq((TestData.bank2_value * 34.2).accounting_norm)
    @bank2.balance.side.should eq(Balance::ACTIVE)
    @forex4.balance.amount.should eq(t.fact.amount * @forex4.rate)
    @forex4.balance.value.should eq(t.fact.amount * @forex4.rate)
    @forex4.balance.side.should eq(Balance::ACTIVE)
    Income.open.count.should eq(1)
    Income.all.count.should eq(2)

    income = Income.where("incomes.paid IS NOT NULL").first
    income.should_not be_nil
    income.value.should eq(TestData.profit)
    income.side.should eq(Income::PASSIVE)
    income.paid.should eq(t.fact.day)

    TestData.profit += (34.95 - 34.2) * t.fact.amount
    Income.open.first.value.should eq(TestData.profit)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => (2500.0 * 34.95), :from => @forex4, :to => @bank,
                                       :resource => @forex4.take)
    TestData.t_forex4_to_bank = Factory(:txn, :fact => fact)
    State.open.count.should eq(7)
    @forex4.state.amount.should eq(2500.0 - 2000.0)
    @forex4.state.resource.should eq(@forex4.give)
    TestData.t_forex4_to_bank.value.should eq(87375.0)
    Income.open.count.should eq(1)

    Balance.open.count.should eq(7)
    @forex4.balance.amount.should eq(2500.0 - 2000.0)
    @forex4.balance.value.should eq(((2500.0 - 2000.0) * 34.95).accounting_norm)
    @forex4.balance.side.should eq(Balance::PASSIVE)

    TestData.bank_value += TestData.t_forex4_to_bank.fact.amount
    @bank.balance.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.value.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(1)
    Income.open.first.value.should eq(TestData.profit)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => 600.0, :from => @bank2, :to => @forex4,
                                       :resource => @forex4.give)
    t = Factory(:txn, :fact => fact)
    State.open.count.should eq(7)
    @forex4.state.amount.should eq((100.0 * 34.95).accounting_norm)
    @forex4.state.resource.should eq(@forex4.take)
    t.earnings.should eq(450.0)

    Balance.open.count.should eq(7)
    @forex4.balance.amount.should eq((100.0 * 34.95).accounting_norm)
    @forex4.balance.value.should eq((100.0 * 34.95).accounting_norm)
    @forex4.balance.side.should eq(Balance::ACTIVE)

    TestData.bank2_value -= 600.0
    @bank2.balance.amount.should eq(TestData.bank2_value)
    @bank2.balance.value.should eq((TestData.bank2_value * 34.2).accounting_norm)
    @bank2.balance.side.should eq(Balance::ACTIVE)

    Income.open.should be_empty
  end

  it "should process gain transaction" do
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => (100.0 * 34.95), :from => @forex4, :to => @bank,
                                   :resource => @forex4.take)
    TestData.t2_forex4_to_bank = Factory(:txn, :fact => fact)
    Balance.open.count.should eq(6)
    @forex4.balances(:force_update).should be_empty

    TestData.bank_value += 100.0 * 34.95
    @bank.balance.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.value.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.side.should eq(Balance::ACTIVE)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => (2 * 2000.0), :from => @bank, :to => @office,
                                   :resource => @office.give)
    TestData.t_bank_to_office = Factory(:txn, :fact => fact)
    State.open.count.should eq(6)
    @office.state.amount.should eq(1.0)
    @office.state.resource.should eq(@office.take)

    Balance.open.count.should eq(6)
    TestData.bank_value -= 2 * 2000.0
    @bank.balance.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.value.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @office.balance.amount.should eq(1.0)
    @office.balance.value.should eq(2000.0)
    @office.balance.side.should eq(Balance::ACTIVE)
    Income.open.should be_empty

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 25, 12, 0, 0),
                                   :amount => 50.0, :from => @bank, :to => Deal.income,
                                   :resource => @bank.take)
    Factory(:txn, :fact => fact)
    Balance.open.count.should eq(6)
    TestData.bank_value -= 50.0
    @bank.balance.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.value.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(1)
    TestData.profit += (34.95 - 34.2) * 600.0 - 50.0
    Income.open.first.value.should eq(TestData.profit)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 26, 12, 0, 0),
                                   :amount => 50.0, :from => Deal.income, :to => @bank,
                                   :resource => @bank.give)
    Factory(:txn, :fact => fact)
    Balance.open.count.should eq(6)
    TestData.bank_value += 50.0
    @bank.balance.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.value.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.side.should eq(Balance::ACTIVE)
    Income.open.should be_empty
  end

  it "should process direct gains losses" do
    TestData.profit += 50.0
    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => (400.0 * 34.95), :from => @forex4, :to => @bank,
                                   :resource => @bank.give)
    Factory(:txn, :fact => fact)
    Balance.open.count.should eq(7)
    @forex4.balance.amount.should eq(400.0)
    @forex4.balance.value.should eq((400.0 * 34.95).accounting_norm)
    @forex4.balance.side.should eq(Balance::PASSIVE)
    TestData.bank_value += 400.0 * 34.95
    @bank.balance.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.value.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.side.should eq(Balance::ACTIVE)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => 400.0, :from => @bank2, :to => Deal.income,
                                   :resource => @bank2.take)
    Factory(:txn, :fact => fact)
    Balance.open.count.should eq(7)
    TestData.bank2_value -= 400.0
    @bank2.balance.amount.should eq(TestData.bank2_value.accounting_norm)
    @bank2.balance.value.should eq((TestData.bank2_value * 34.2).accounting_norm)
    @bank2.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(1)
    TestData.profit -= 400.0 * 34.2
    Income.open.first.value.should eq(TestData.profit.accounting_norm)

    fact = Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => 400.0, :from => Deal.income, :to => @forex4,
                                   :resource => @forex4.give)
    Factory(:txn, :fact => fact)
    Balance.open.count.should eq(6)
    @share2.balance.side.should eq(Balance::PASSIVE)
    @share2.balance.amount.should eq(100000.0 / @share2.rate)
    @share2.balance.value.should eq(100000.0)
    @share1.balance.side.should eq(Balance::PASSIVE)
    @share1.balance.amount.should eq(142000.0 / @share1.rate)
    @share1.balance.value.should eq(142000.0)
    @purchase.balance.side.should eq(Balance::ACTIVE)
    @purchase.balance.amount.should eq(1.0)
    @purchase.balance.value.should eq(70000.0)
    @bank.balance.side.should eq(Balance::ACTIVE)
    @bank.balance.amount.should eq(TestData.bank_value.accounting_norm)
    @bank.balance.value.should eq(TestData.bank_value.accounting_norm)
    @bank2.balance.side.should eq(Balance::ACTIVE)
    @bank2.balance.amount.should eq(TestData.bank2_value.accounting_norm)
    @bank2.balance.value.should eq((TestData.bank2_value * 34.2).accounting_norm)
    @office.balance.side.should eq(Balance::ACTIVE)
    @office.balance.amount.should eq(1.0)
    @office.balance.value.should eq(2000.0)
  end

  it "should produce transcript" do
    txns = @bank.txns(DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 22, 12, 0, 0))
    txns.count.should eq(2)
    txns.each { |txn| txn.should be_kind_of(Txn); [txn.fact.from, txn.fact.to].should include(@bank) }
    txns = @bank.txns(DateTime.civil(2011, 11, 23, 12, 0, 0), DateTime.civil(2011, 11, 23, 12, 0, 0))
    txns.count.should eq(4)
    txns.each { |txn| txn.should be_kind_of(Txn); [txn.fact.from, txn.fact.to].should include(@bank) }

    balances = @bank.balances_by_time_frame(DateTime.civil(2011, 11, 22, 12, 0, 0),
                                            DateTime.civil(2011, 11, 22, 12, 0, 0))
    balances.count.should eq(1)
    balances.first.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    balances.first.paid.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))

    tr = Transcript.new(@bank, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.deal.should eq(@bank)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(100000.0 + 142000.0)
    tr.closing.value.should eq(100000.0 + 142000.0)
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(2)
    tr.to_a.should =~ [TestData.t_share2_to_bank, TestData.t_share_to_bank]


    tr = Transcript.new(@bank, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 23, 12, 0, 0))
    tr.deal.should eq(@bank)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(100000.0 + 142000.0 - 70000.0 +
                                (1000.0 * (@forex2.rate - (1 / @forex1.rate))).accounting_norm - (5000.0 * 34.2))
    tr.closing.value.should eq(100000.0 + 142000.0 - 70000.0 +
                              (1000.0 * (@forex2.rate - (1 / @forex1.rate))).accounting_norm - (5000.0 * 34.2))
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(6)
    tr.to_a.should =~ [TestData.t_share2_to_bank, TestData.t_share_to_bank, TestData.t_bank_to_forex,
                       TestData.t_bank_to_forex3, TestData.t_bank_to_purchase, TestData.t_forex2_to_bank]

    tr.total_debits.should eq(100000.0 + 142000.0 + 1000.0 * @forex2.rate)
    tr.total_debits_value.should eq(100000.0 + 142000.0 + 1000.0 * @forex2.rate)

    tr.total_credits.should eq(70000.0 + 5000.0 * 34.2 + 34950.0)
    tr.total_credits_value.should eq(70000.0 + 5000.0 * 34.2 + 34950.0)


    tr = Transcript.new(@bank, DateTime.civil(2011, 11, 23, 12, 0, 0), DateTime.civil(2011, 11, 24, 12, 0, 0))
    tr.deal.should eq(@bank)
    tr.start.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 24, 12, 0, 0))

    tr.opening.amount.should eq(100000.0 + 142000.0)
    tr.opening.value.should eq(100000.0 + 142000.0)
    tr.opening.side.should eq(Balance::ACTIVE)
    tr.closing.amount.should eq(100000.0 + 142000.0 - 70000.0 +
                                (1000.0 * (@forex2.rate - (1 / @forex1.rate))).accounting_norm - (5000.0 * 34.2) +
                                (2500.0 * 34.95) + (100 * 34.95) - (2 * 2000.0))
    tr.closing.value.should eq(100000.0 + 142000.0 - 70000.0 +
                              (1000.0 * (@forex2.rate - (1 / @forex1.rate))).accounting_norm - (5000.0 * 34.2) +
                              (2500.0 * 34.95) + (100 * 34.95) - (2 * 2000.0))
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(7)
    tr.to_a.should =~ [TestData.t_bank_to_forex, TestData.t_bank_to_forex3, TestData.t_bank_to_purchase,
                       TestData.t_forex2_to_bank,
                       TestData.t_forex4_to_bank, TestData.t2_forex4_to_bank, TestData.t_bank_to_office]


    tr = Transcript.new(@bank, DateTime.civil(2011, 11, 21, 12, 0, 0), DateTime.civil(2011, 11, 21, 12, 0, 0))
    tr.deal.should eq(@bank)
    tr.start.should eq(DateTime.civil(2011, 11, 21, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 21, 12, 0, 0))
    tr.opening.should be_nil
    tr.closing.should be_nil
    tr.should be_empty

    tr = Transcript.new(@purchase, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 23, 12, 0, 0))
    tr.deal.should eq(@purchase)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(1.0)
    tr.closing.value.should eq(70000.0)
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(1)
    tr.to_a.should =~ [TestData.t_bank_to_purchase]
  end

  it "should produce pnl transcript" do
    tr = Transcript.new(Deal.income, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 27, 12, 0, 0))
    tr.deal.should eq(Deal.income)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 27, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.value.should eq((400.0 * (34.95 - 34.2)).accounting_norm)
    tr.closing.side.should eq(Income::PASSIVE)

    tr.count.should eq(8)
    tr.first.fact.amount.should eq(1000.0)
    tr.first.value.should eq(1000.0 * 34.95)
    tr.first.earnings.should eq((1000.0 * (35.0 - 34.95)).accounting_norm)
    tr.last.fact.amount.should eq(400.0)
    tr.last.value.should eq(0.0)
    tr.last.earnings.should eq((400.0 * 34.95).accounting_norm)
  end

  it "should produce balance sheet" do
    bs = Balance.find_all_by_time_frame DateTime.now, DateTime.now
    bs.count.should eq(6)
    (bs + Income.find_all_by_time_frame(DateTime.now, DateTime.now)).count.should eq(7)

    dt = DateTime.now
    dt.should eq(BalanceSheet.new(dt).date)

    bs = BalanceSheet.new
    bs.count.should eq(7)
    bs.last.value.should eq((400.0 * (34.95 - 34.2)).accounting_norm)
    bs.last.side.should eq(Income::PASSIVE)
    bs.assets.should eq(242300.0)
    bs.liabilities.should eq(242300.0)

    bs = BalanceSheet.new DateTime.civil(2011, 11, 26, 12, 0, 0)
    bs.count.should eq(6)
    bs.assets.should eq(242000.0)
    bs.liabilities.should eq(242000.0)
    bs.to_a.should =~ Balance.find_all_by_time_frame(DateTime.civil(2011, 11, 27, 12, 0, 0),
                                                     DateTime.civil(2011, 11, 26, 12, 0, 0))
  end

  it "should produce general ledger" do
    Txn.all.count.should eq(20)
    GeneralLedger.new.count.should eq(20)
    GeneralLedger.new.to_a.should =~ Txn.all
  end
end
