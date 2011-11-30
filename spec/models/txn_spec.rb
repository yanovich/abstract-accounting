# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Txn do
  it "should have next behaviour" do
    rub =  Factory(:chart).currency
    eur = Factory(:money)
    aasii = Factory(:asset)
    share2 = Factory(:deal, :give => aasii, :take => rub, :rate => 10000.0)
    share1 = Factory(:deal, :give => aasii, :take => rub, :rate => 10000.0)
    bank = Factory(:deal, :give => rub, :take => rub, :rate => 1.0)
    purchase = Factory(:deal, :give => rub, :rate => 0.0000142857143)
    bank2 = Factory(:deal, :give => eur, :take => eur, :rate => 1.0)
    forex1 = Factory(:deal, :give => rub, :take => eur, :rate => 0.028612303)
    forex2 = Factory(:deal, :give => eur, :take => rub, :rate => 35.0)

    Factory(:fact, :day => DateTime.civil(2011, 11, 22, 12, 0, 0), :from => share2,
            :to => bank, :resource => rub, :amount => 100000.0)
    Factory(:fact, :day => DateTime.civil(2011, 11, 22, 12, 0, 0), :from => share1,
            :to => bank, :resource => rub, :amount => 142000.0)
    Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => bank,
            :to => purchase, :resource => rub, :amount => 70000.0)
    Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => forex1,
            :to => bank2, :resource => eur, :amount => 1000.0)
    Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => bank,
            :to => forex1, :resource => rub, :amount => 34950.0)
    Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => bank2,
            :to => forex2, :resource => eur, :amount => 1000.0)

    Fact.pendings.should_not be_nil
    Fact.pendings.count.should eq(6)
    p_fact = Fact.pendings.first
    t_share2_to_bank = Txn.create!(:fact => p_fact)

    should validate_presence_of :value
    should validate_presence_of :fact_id
    should validate_presence_of :status
    should validate_uniqueness_of :fact_id
    should belong_to :fact

    t_share2_to_bank.value.should eq(p_fact.amount)
    share2.balance.should_not be_nil
    share2.balance.resource.should eq(p_fact.from.give)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(p_fact.amount / share2.rate)
    share2.balance.value.should eq(p_fact.amount)
    bank.balance.should_not be_nil
    bank.balance.resource.should eq(p_fact.to.take)
    bank.balance.side.should eq(Balance::ACTIVE)
    bank.balance.amount.should eq(p_fact.amount)
    bank.balance.value.should eq(p_fact.amount)

    Fact.pendings.count.should eq(5)
    p_fact = Fact.pendings.first
    t_share_to_bank = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(3)
    t_share_to_bank.value.should eq(p_fact.amount)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(100000.0 / share2.rate)
    share2.balance.value.should eq(100000.0)
    bank.balance.side.should eq(Balance::ACTIVE)
    bank.balance.amount.should eq(100000.0 + 142000.0)
    bank.balance.value.should eq(100000.0 + 142000.0)
    share1.balance.side.should eq(Balance::PASSIVE)
    share1.balance.amount.should eq(142000.0 / share1.rate)
    share1.balance.value.should eq(142000.0)

    Fact.pendings.count.should eq(4)
    p_fact = Fact.pendings.first
    t_bank_to_purchase = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(4)
    t_bank_to_purchase.value.should eq(p_fact.amount)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(100000.0 / share2.rate)
    share2.balance.value.should eq(100000.0)
    bank.balance.side.should eq(Balance::ACTIVE)
    bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0)
    bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0)
    share1.balance.side.should eq(Balance::PASSIVE)
    share1.balance.amount.should eq(142000.0 / share1.rate)
    share1.balance.value.should eq(142000.0)
    purchase.balance.side.should eq(Balance::ACTIVE)
    purchase.balance.amount.should eq(1.0)
    purchase.balance.value.should eq(70000.0)
    bank.balances.where("balances.paid IS NOT NULL").count.should eq(1)
    b = bank.balances.where("balances.paid IS NOT NULL").first
    b.side.should eq(Balance::ACTIVE)
    b.amount.should eq(100000.0 + 142000.0)
    b.value.should eq(100000.0 + 142000.0)

    Fact.pendings.count.should eq(3)
    p_fact = Fact.pendings.first
    t = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(6)
    t.value.should eq((1000.0 / forex1.rate).accounting_norm)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(100000.0 / share2.rate)
    share2.balance.value.should eq(100000.0)
    bank.balance.side.should eq(Balance::ACTIVE)
    bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0)
    bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0)
    share1.balance.side.should eq(Balance::PASSIVE)
    share1.balance.amount.should eq(142000.0 / share1.rate)
    share1.balance.value.should eq(142000.0)
    purchase.balance.side.should eq(Balance::ACTIVE)
    purchase.balance.amount.should eq(1.0)
    purchase.balance.value.should eq(70000.0)
    forex1.balance.side.should eq(Balance::PASSIVE)
    forex1.balance.amount.should eq((1000.0 / forex1.rate).accounting_norm)
    forex1.balance.value.should eq((1000.0 / forex1.rate).accounting_norm)
    bank2.balance.side.should eq(Balance::ACTIVE)
    bank2.balance.amount.should eq(1000.0)
    bank2.balance.value.should eq((1000.0 / forex1.rate).accounting_norm)

    Fact.pendings.count.should eq(2)
    p_fact = Fact.pendings.first
    t_bank_to_forex = Txn.create!(:fact => p_fact)
    Balance.open.count.should eq(5)
    t_bank_to_forex.value.should eq((1000.0 / forex1.rate).accounting_norm)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(100000.0 / share2.rate)
    share2.balance.value.should eq(100000.0)
    bank.balance.side.should eq(Balance::ACTIVE)
    bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0 -
                                (1000.0 / forex1.rate).accounting_norm)
    bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0 -
                               (1000.0 / forex1.rate).accounting_norm)
    share1.balance.side.should eq(Balance::PASSIVE)
    share1.balance.amount.should eq(142000.0 / share1.rate)
    share1.balance.value.should eq(142000.0)
    purchase.balance.side.should eq(Balance::ACTIVE)
    purchase.balance.amount.should eq(1.0)
    purchase.balance.value.should eq(70000.0)
    forex1.balance.should be_nil
    bank2.balance.side.should eq(Balance::ACTIVE)
    bank2.balance.amount.should eq(1000.0)
    bank2.balance.value.should eq((1000.0 / forex1.rate).accounting_norm)

    Fact.pendings.count.should eq(1)
    p_fact = Fact.pendings.first
    Txn.create!(:fact => p_fact)
    Fact.find(p_fact.id).txn.value.should eq((1000.0 / forex1.rate).accounting_norm)
    Fact.find(p_fact.id).txn.status.should eq(1)
    Fact.find(p_fact.id).txn.earnings.should eq((1000.0 * (forex2.rate -
                                                (1/forex1.rate))).accounting_norm)
    Balance.open.count.should eq(5)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(100000.0 / share2.rate)
    share2.balance.value.should eq(100000.0)
    bank.balance.side.should eq(Balance::ACTIVE)
    bank.balance.amount.should eq(100000.0 + 142000.0 - 70000.0 -
                                (1000.0 / forex1.rate).accounting_norm)
    bank.balance.value.should eq(100000.0 + 142000.0 - 70000.0 -
                               (1000.0 / forex1.rate).accounting_norm)
    share1.balance.side.should eq(Balance::PASSIVE)
    share1.balance.amount.should eq(142000.0 / share1.rate)
    share1.balance.value.should eq(142000.0)
    purchase.balance.side.should eq(Balance::ACTIVE)
    purchase.balance.amount.should eq(1.0)
    purchase.balance.value.should eq(70000.0)
    forex1.balance.should be_nil
    bank2.balance.should be_nil
    forex2.balance.side.should eq(Balance::ACTIVE)
    forex2.balance.amount.should eq(1000.0 * forex2.rate)
    forex2.balance.value.should eq(1000.0 * forex2.rate)

    Income.open.count.should eq(1)
    profit =(1000.0 * (forex2.rate - (1/forex1.rate))).accounting_norm
    Income.open.first.value.should eq(profit)
    Fact.pendings.count.should eq(0)

    #loss_transaction
    t_forex2_to_bank = Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                                      :from => forex2,
                                                      :to => bank,
                                                      :resource => forex2.take,
                                                      :amount => 1000.0 * forex2.rate))
    Balance.open.count.should eq(4)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(100000.0 / share2.rate)
    share2.balance.value.should eq(100000.0)
    share1.balance.side.should eq(Balance::PASSIVE)
    share1.balance.amount.should eq(142000.0 / share1.rate)
    share1.balance.value.should eq(142000.0)
    purchase.balance.side.should eq(Balance::ACTIVE)
    purchase.balance.amount.should eq(1.0)
    purchase.balance.value.should eq(70000.0)
    bank.balance.side.should eq(Balance::ACTIVE)
    value = 100000.0 + 142000.0 - 70000.0 + (1000.0 * (forex2.rate - (1 / forex1.rate))).accounting_norm
    bank.balance.amount.should eq(value)
    bank.balance.value.should eq(value)
    forex1.balance.should be_nil
    bank2.balance.should be_nil
    forex2.balance.should be_nil

    forex = Factory(:deal, :rate => (1 / 34.2), :give => bank.give, :take => bank2.take)
    t_bank_to_forex3 = Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                          :amount => (5000.0 / forex.rate).accounting_norm,
                                          :from => bank, :to => forex, :resource => forex.give))
    Balance.open.count.should eq(5)
    bank.balance.side.should eq(Balance::ACTIVE)
    value -= (5000.0 / forex.rate).accounting_norm
    bank.balance.amount.should eq(value)
    bank.balance.value.should eq(value)
    forex.balance.side.should eq(Balance::ACTIVE)
    forex.balance.amount.should eq(5000.0)
    forex.balance.value.should eq((5000.0 / forex.rate).accounting_norm)

    Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :amount => 5000.0,
                                          :from => forex, :to => bank2, :resource => forex.take))
    Balance.open.count.should eq(5)
    bank2.balance.side.should eq(Balance::ACTIVE)
    bank2.balance.amount.should eq(5000.0)
    bank2.balance.value.should eq((5000.0 / forex.rate).accounting_norm)
    forex.balance.should be_nil

    office = Factory(:deal, :rate => (1 / 2000.0), :give => bank.give, :take => Factory(:asset))
    f = Factory(:fact, :day => DateTime.civil(2011, 11, 23, 12, 0, 0), :from => office,
                :to => Deal.income, :resource => office.take)
    State.open.count.should eq(6)
    office.state.amount.should eq((1 / office.rate).accounting_norm)
    office.state.resource.should eq(bank.give)
    bank.state.amount.should eq(value.accounting_norm)
    bank.state.resource.should eq(bank.give)
    t = Txn.create!(:fact => f)
    Balance.open.count.should eq(6)
    t.to_balance.should be_nil
    office.balance.amount.should eq((1 / office.rate).accounting_norm)
    office.balance.value.should eq((1 / office.rate).accounting_norm)
    office.balance.side.should eq(Balance::PASSIVE)

    Income.open.count.should eq(1)
    profit -= (1 / office.rate).accounting_norm
    Income.open.first.value.should eq(profit)

    #split_transaction
    forex = Factory(:deal, :rate => 34.95, :give => bank2.give, :take => bank.give)
    t = Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => 2000.0, :from => bank2, :to => forex,
                                       :resource => forex.give))
    Balance.open.count.should eq(7)
    euros = 5000.0 - t.fact.amount
    bank2.balance.amount.should eq(euros)
    bank2.balance.value.should eq((euros * 34.2).accounting_norm)
    bank2.balance.side.should eq(Balance::ACTIVE)
    forex.balance.amount.should eq(t.fact.amount * forex.rate)
    forex.balance.value.should eq(t.fact.amount * forex.rate)
    forex.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(1)
    Income.all.count.should eq(2)

    income = Income.where("incomes.paid IS NOT NULL").first
    income.should_not be_nil
    income.value.should eq(profit)
    income.side.should eq(Income::PASSIVE)
    income.paid.should eq(t.fact.day)

    profit += (34.95 - 34.2) * t.fact.amount
    Income.open.first.value.should eq(profit)

    t_forex4_to_bank = Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => (2500.0 * 34.95), :from => forex, :to => bank,
                                       :resource => forex.take))
    State.open.count.should eq(7)
    forex.state.amount.should eq(2500.0 - 2000.0)
    forex.state.resource.should eq(forex.give)
    t_forex4_to_bank.value.should eq(87375.0)
    Income.open.count.should eq(1)

    Balance.open.count.should eq(7)
    forex.balance.amount.should eq(2500.0 - 2000.0)
    forex.balance.value.should eq(((2500.0 - 2000.0) * 34.95).accounting_norm)
    forex.balance.side.should eq(Balance::PASSIVE)

    rubs = 100000.0 + 142000.0 - 70000.0 +
      (1000.0 * (forex2.rate - 1 / forex1.rate))
    rubs -= (5000.0 * 34.2).accounting_norm
    rubs += t_forex4_to_bank.fact.amount
    bank.balance.amount.should eq(rubs.accounting_norm)
    bank.balance.value.should eq(rubs.accounting_norm)
    bank.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(1)
    Income.open.first.value.should eq(profit)

    t = Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => 600.0, :from => bank2, :to => forex,
                                       :resource => forex.give))
    State.open.count.should eq(7)
    forex.state.amount.should eq((100.0 * 34.95).accounting_norm)
    forex.state.resource.should eq(forex.take)
    t.earnings.should eq(450.0)

    Balance.open.count.should eq(7)
    forex.balance.amount.should eq((100.0 * 34.95).accounting_norm)
    forex.balance.value.should eq((100.0 * 34.95).accounting_norm)
    forex.balance.side.should eq(Balance::ACTIVE)

    euros -= 600.0
    bank2.balance.amount.should eq(euros)
    bank2.balance.value.should eq((euros * 34.2).accounting_norm)
    bank2.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(0)

    #gain_transaction
    t2_forex4_to_bank = Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => (100.0 * 34.95), :from => forex, :to => bank,
                                   :resource => forex.take))
    Balance.open.count.should eq(6)
    forex.balances.count.should eq(0)

    rubs += 100.0 * 34.95
    bank.balance.amount.should eq(rubs.accounting_norm)
    bank.balance.value.should eq(rubs.accounting_norm)
    bank.balance.side.should eq(Balance::ACTIVE)

    t_bank_to_office = Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => (2 * 2000.0), :from => bank, :to => office,
                                   :resource => office.give))
    State.open.count.should eq(6)
    office.state.amount.should eq(1.0)
    office.state.resource.should eq(office.take)

    Balance.open.count.should eq(6)
    rubs -= 2 * 2000.0
    bank.balance.amount.should eq(rubs.accounting_norm)
    bank.balance.value.should eq(rubs.accounting_norm)
    bank.balance.side.should eq(Balance::ACTIVE)
    office.balance.amount.should eq(1.0)
    office.balance.value.should eq(2000.0)
    office.balance.side.should eq(Balance::ACTIVE)
    Income.open.count.should eq(0)

    Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 25, 12, 0, 0),
                                   :amount => 50.0, :from => bank, :to => Deal.income,
                                   :resource => bank.take))
    Balance.open.count.should eq(6)
    rubs -= 50.0
    bank.balance.amount.should eq(rubs.accounting_norm)
    bank.balance.value.should eq(rubs.accounting_norm)
    bank.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(1)
    profit += (34.95 - 34.2) * 600.0 - 50.0
    Income.open.first.value.should eq(profit)

    Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 26, 12, 0, 0),
                                   :amount => 50.0, :from => Deal.income, :to => bank,
                                   :resource => bank.give))
    Balance.open.count.should eq(6)
    rubs += 50.0
    bank.balance.amount.should eq(rubs.accounting_norm)
    bank.balance.value.should eq(rubs.accounting_norm)
    bank.balance.side.should eq(Balance::ACTIVE)
    Income.open.count.should eq(0)

    #direct_gains_losses
    profit += 50.0
    Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => (400.0 * 34.95), :from => forex, :to => bank,
                                   :resource => bank.give))
    Balance.open.count.should eq(7)
    forex.balance.amount.should eq(400.0)
    forex.balance.value.should eq((400.0 * 34.95).accounting_norm)
    forex.balance.side.should eq(Balance::PASSIVE)
    rubs += 400.0 * 34.95
    bank.balance.amount.should eq(rubs.accounting_norm)
    bank.balance.value.should eq(rubs.accounting_norm)
    bank.balance.side.should eq(Balance::ACTIVE)

    Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => 400.0, :from => bank2, :to => Deal.income,
                                   :resource => bank2.take))
    Balance.open.count.should eq(7)
    euros -= 400.0
    bank2.balance.amount.should eq(euros.accounting_norm)
    bank2.balance.value.should eq((euros * 34.2).accounting_norm)
    bank2.balance.side.should eq(Balance::ACTIVE)

    Income.open.count.should eq(1)
    profit -= 400.0 * 34.2
    Income.open.first.value.should eq(profit.accounting_norm)

    Factory(:txn, :fact => Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => 400.0, :from => Deal.income, :to => forex,
                                   :resource => forex.give))
    Balance.open.count.should eq(6)
    share2.balance.side.should eq(Balance::PASSIVE)
    share2.balance.amount.should eq(100000.0 / share2.rate)
    share2.balance.value.should eq(100000.0)
    share1.balance.side.should eq(Balance::PASSIVE)
    share1.balance.amount.should eq(142000.0 / share1.rate)
    share1.balance.value.should eq(142000.0)
    purchase.balance.side.should eq(Balance::ACTIVE)
    purchase.balance.amount.should eq(1.0)
    purchase.balance.value.should eq(70000.0)
    bank.balance.side.should eq(Balance::ACTIVE)
    bank.balance.amount.should eq(rubs.accounting_norm)
    bank.balance.value.should eq(rubs.accounting_norm)
    bank2.balance.side.should eq(Balance::ACTIVE)
    bank2.balance.amount.should eq(euros.accounting_norm)
    bank2.balance.value.should eq((euros * 34.2).accounting_norm)
    office.balance.side.should eq(Balance::ACTIVE)
    office.balance.amount.should eq(1.0)
    office.balance.value.should eq(2000.0)
  end
end
