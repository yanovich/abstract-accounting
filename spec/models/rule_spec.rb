# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Rule do
  before(:all) do
    DatabaseCleaner.start
  end

  after(:all) do
    DatabaseCleaner.clean
  end
  let(:rub) { Factory(:chart).currency }

  it "should have next behaviour" do
    should validate_presence_of :deal_id
    should validate_presence_of :from_id
    should validate_presence_of :to_id
    should validate_presence_of :rate
    should allow_value(true).for(:fact_side)
    should allow_value(false).for(:fact_side)
    should allow_value(true).for(:change_side)
    should allow_value(false).for(:change_side)
    should belong_to :deal
    should belong_to :from
    should belong_to :to
    should have_many Rule.versions_association_name
  end

  it "should have rule workflow" do
    x = Factory(:asset)
    y = Factory(:asset)
    keeper = Factory(:entity)
    shipment = Factory(:asset)
    supplier = Factory(:entity)
    purchase_x = Factory(:deal, :entity => supplier, :give => rub,
      :take => x, :rate => (1.0 / 100.0))
    purchase_y = Factory(:deal, :entity => supplier, :give => rub,
      :take => y, :rate => (1.0 / 150.0))
    storage_x = Factory(:deal, :entity => keeper, :give => x, :take => x)
    storage_y = Factory(:deal, :entity => keeper, :give => y, :take => y)
    sale_x = Factory(:deal, :entity => supplier, :give => x, :take => rub,
      :rate => 120.0)
    sale_y = Factory(:deal, :entity => supplier, :give => y, :take => rub,
      :rate => 160.0)
    f = Factory(:fact, :amount => 50.0, :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
      :from => purchase_x, :to => storage_x, :resource => purchase_x.take)
    Txn.create!(:fact => f)
    f = Factory(:fact, :amount => 50.0, :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
      :from => purchase_y, :to => storage_y, :resource => purchase_y.take)
    Txn.create!(:fact => f)
    Balance.open.count.should eq(4), "Wrong open balances count"
    b = purchase_x.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(5000.0), "Wrong balance amount"
    b.value.should eq(5000.0), "Wrong balance value"
    b.side.should eq(Balance::PASSIVE), "Wrong balance side"
    b = purchase_y.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(7500.0), "Wrong balance amount"
    b.value.should eq(7500.0), "Wrong balance value"
    b.side.should eq(Balance::PASSIVE), "Wrong balance side"
    b = storage_x.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(50.0), "Wrong balance amount"
    b.value.should eq(5000.0), "Wrong balance value"
    b.side.should eq(Balance::ACTIVE), "Wrong balance side"
    b = storage_y.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(50.0), "Wrong balance amount"
    b.value.should eq(7500.0), "Wrong balance value"
    b.side.should eq(Balance::ACTIVE), "Wrong balance side"

    shipment_deal = Factory(:deal, :entity => supplier, :give => shipment,
      :take => shipment, :isOffBalance => true)
    Deal.find(shipment_deal.id).isOffBalance.should be_true,
      "Wrong saved value for is off balance"

    Factory(:rule, :deal => shipment_deal, :from => storage_x,
      :to => sale_x, :rate => 27.0)
    Rule.count.should eq(1), "Rule count is wrong"
    Factory(:rule, :deal => shipment_deal, :from => storage_y,
      :to => sale_y, :rate => 42.0)
    Rule.count.should eq(2), "Rule count is wrong"

    f = Factory(:fact, :day => DateTime.civil(2008, 9, 22, 12, 0, 0),
      :from => nil, :to => shipment_deal, :resource => shipment_deal.give)

    State.open.count.should eq(7), "Wrong open states count"
    s = purchase_x.state
    s.should_not be_nil, "State is nil"
    s.amount.should eq(5000.0), "State amount is wrong"

    s = purchase_y.state
    s.should_not be_nil, "State is nil"
    s.amount.should eq(7500.0), "State amount is wrong"

    s = storage_x.state
    s.should_not be_nil, "State is nil"
    s.amount.should eq(23.0), "State amount is wrong"

    s = storage_y.state
    s.should_not be_nil, "State is nil"
    s.amount.should eq(8.0), "State amount is wrong"

    s = sale_x.state
    s.should_not be_nil, "State is nil"
    s.amount.should eq((120.0 * 27.0).accounting_norm), "State amount is wrong"

    s = sale_y.state
    s.should_not be_nil, "State is nil"
    s.amount.should eq((160.0 * 42.0).accounting_norm), "State amount is wrong"

    s = shipment_deal.state
    s.should_not be_nil, "State is nil"
    s.amount.should eq(1.0), "State amount is wrong"

    Txn.create!(:fact => f)
    Balance.open.count.should eq(6), "Wrong open balances count"

    b = purchase_x.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(5000.0), "Wrong balance amount"
    b.value.should eq(5000.0), "Wrong balance value"
    b.side.should eq(Balance::PASSIVE), "Wrong balance side"
    b = purchase_y.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(7500.0), "Wrong balance amount"
    b.value.should eq(7500.0), "Wrong balance value"
    b.side.should eq(Balance::PASSIVE), "Wrong balance side"
    b = storage_x.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(23.0), "Wrong balance amount"
    b.value.should eq(2300.0), "Wrong balance value"
    b.side.should eq(Balance::ACTIVE), "Wrong balance side"
    b = storage_y.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(8.0), "Wrong balance amount"
    b.value.should eq(1200.0), "Wrong balance value"
    b.side.should eq(Balance::ACTIVE), "Wrong balance side"
    b = sale_x.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(3240.0), "Wrong balance amount"
    b.value.should eq(3240.0), "Wrong balance value"
    b.side.should eq(Balance::ACTIVE), "Wrong balance side"
    b = sale_y.balance
    b.should_not be_nil, "Balance is nil"
    b.amount.should eq(6720.0), "Wrong balance amount"
    b.value.should eq(6720.0), "Wrong balance value"
    b.side.should eq(Balance::ACTIVE), "Wrong balance side"
  end

  it "should apply filter" do
    storekeeper = Factory(:entity)
    sonyvaio = Factory(:asset)
    svwarehouse = Factory(:deal, :entity => storekeeper, :give => sonyvaio,
      :take => sonyvaio)
    buyer = Factory(:entity)
    svsale = Factory(:deal, :rate => 80000, :entity => buyer,
      :give => sonyvaio, :take => rub)

    sbrfbank = Factory(:entity)
    bankaccount = Factory(:deal, :entity => sbrfbank, :give => rub,
      :take => rub)
    equipmentsupl = Factory(:entity)
    purchase = Factory(:deal, :entity => equipmentsupl, :rate => 0.0000142857143,
      :give => rub, :take => sonyvaio)
    Factory(:rule, :deal => svwarehouse, :from => bankaccount,
      :to => purchase, :rate => (1 / purchase.rate).accounting_norm)

    State.count.should eq(9), "Wrong state count"
    fact = Factory(:fact, :day => DateTime.civil(2011, 9, 1, 12, 0, 0), :amount => 300,
      :from => purchase, :to => svwarehouse, :resource => svwarehouse.give)
    State.count.should eq(11), "Wrong state count"
    State.open.count.should eq(9), "Wrong open state count"
    state = purchase.state
    state.should be_nil, "Purchase state is not nil"
    state = bankaccount.state
    state.should_not be_nil, "Bankaccount state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq((1 / purchase.rate).accounting_norm * fact.amount),
      "Wrong state amount"
    state = svwarehouse.state
    state.should_not be_nil, "Warehouse bank state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount), "Wrong state amount"

    buyerbank = Factory(:deal, :entity => sbrfbank, :give => rub,
      :take => rub)

    Factory(:rule, :deal => svsale, :from => buyerbank, :to => bankaccount)

    State.open.count.should eq(9), "Wrong open state count"
    Factory(:fact, :day => DateTime.civil(2011, 9, 2, 12, 0, 0),
      :amount => 300, :from => purchase, :to => svsale, :resource => svsale.give)
    State.count.should eq(15), "Wrong state count"
    State.open.count.should eq(12), "Wrong open state count"
    state = purchase.state
    state.should_not be_nil, "Purchase state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq((fact.amount / purchase.rate).accounting_norm),
      "Wrong state amount"
    state = bankaccount.state
    state.should_not be_nil, "Bankaccount state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount * svsale.rate - ((1 / purchase.rate).accounting_norm * 300)),
      "Wrong state amount"
    state = svwarehouse.state
    state.should_not be_nil, "Warehouse bank state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount), "Wrong state amount"
    state = buyerbank.state
    state.should_not be_nil, "Buyer bank state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(fact.amount * svsale.rate), "Wrong state amount"
    state = svsale.state
    state.should_not be_nil, "Sale state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount * svsale.rate), "Wrong state amount"

    svsale2 = Factory(:deal, :rate => 70000, :entity => buyer, :give => sonyvaio,
      :take => rub)

    Factory(:rule, :deal => purchase, :from => svsale2, :to => bankaccount,
      :fact_side => true)

    State.open.count.should eq(12), "Wrong open state count"
    Factory(:fact, :day => DateTime.civil(2011, 9, 2, 12, 0, 0),
      :amount => 300, :from => purchase, :to => svsale2, :resource => svsale2.give)
    State.open.count.should eq(12), "Wrong open state count"
    assert_equal 12, State.open.count, "Wrong state count"
    state = purchase.state
    state.should_not be_nil, "Purchase state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(2 * (fact.amount / purchase.rate).accounting_norm),
      "Wrong state amount"
    state = bankaccount.state
    state.should_not be_nil, "Bankaccount state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount * svsale.rate), "Wrong state amount"
    state = svwarehouse.state
    state.should_not be_nil, "Warehouse bank state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount), "Wrong state amount"
    state = buyerbank.state
    state.should_not be_nil, "Buyer bank state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(fact.amount * svsale.rate), "Wrong state amount"
    state = svsale.state
    state.should_not be_nil, "Sale state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount * svsale.rate), "Wrong state amount"
    state = svsale2.state
    state.should be_nil, "Sale state is not nil"

    galaxy = Factory(:asset)
    purchase_g = Factory(:deal, :entity => equipmentsupl, :rate => 0.0002,
      :give => rub, :take => galaxy)
    sale_g = Factory(:deal, :rate => 5000, :entity => buyer,
      :give => galaxy, :take => rub)

    Factory(:fact, :day => DateTime.civil(2011, 9, 3, 12, 0, 0),
      :amount => 300, :from => purchase_g, :to => sale_g, :resource => sale_g.give)
    state = purchase_g.state
    state.should_not be_nil, "Buyer bank state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(fact.amount / purchase_g.rate), "Wrong state amount"
    state = sale_g.state
    state.should_not be_nil, "Sale state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(fact.amount * sale_g.rate), "Wrong state amount"

    Factory(:rule, :deal => sale_g, :from => bankaccount, :to => purchase_g,
      :fact_side => true, :rate => 5000.0)

    Factory(:fact, :day => DateTime.civil(2011, 9, 4, 12, 0, 0), :amount => sale_g.rate * 200,
      :from => sale_g, :to => bankaccount, :resource => bankaccount.give)
    state = purchase_g.state
    state.should_not be_nil, "Buyer bank state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(300 / purchase_g.rate), "Wrong state amount"
    state = sale_g.state
    state.should_not be_nil, "Sale state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(100 * sale_g.rate), "Wrong state amount"

    Factory(:fact, :day => DateTime.civil(2011, 9, 4, 12, 0, 0), :amount => sale_g.rate * 200,
      :from => sale_g, :to => bankaccount, :resource => bankaccount.give)
    state = purchase_g.state
    state.should_not be_nil, "Buyer bank state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(200 / purchase_g.rate), "Wrong state amount"
    state = sale_g.state
    state.should_not be_nil, "Sale state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(100), "Wrong state amount"

    nokia = Factory(:asset)
    purchase_n = Factory(:deal, :rate => 0.00033, :entity => equipmentsupl,
      :give => rub, :take => nokia)
    sale_n = Factory(:deal, :rate => 3000, :entity => buyer,
      :give => nokia, :take => rub)

    Factory(:fact, :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
      :amount => (200 / purchase_n.rate).accounting_norm, :from => bankaccount,
      :to => purchase_n, :resource => purchase_n.give)
    state = purchase_n.state
    state.should_not be_nil, "Purchase state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(200.0), "Wrong state amount"

    Factory(:rule, :deal => purchase_n, :from => sale_n, :to => bankaccount,
      :fact_side => true, :change_side => false, :rate => 3000.0)

    Factory(:fact, :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
      :amount => 100, :from => purchase_n,
      :to => sale_n, :resource => sale_n.give)
    state = purchase_n.state
    state.should_not be_nil, "Purchase state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(100.0), "Wrong state amount"
    state = sale_n.state
    state.should be_nil, "Sale state is not nil"

    nokia33 = Factory(:asset)
    purchase_n33 = Factory(:deal, :rate => 0.00025,
      :entity => equipmentsupl, :give => rub, :take => nokia33)
    sale_n33 = Factory(:deal, :rate => 4000,
      :entity => buyer, :give => nokia33, :take => rub)

    Factory(:rule, :deal => sale_n33, :from => bankaccount, :to => purchase_n33,
      :change_side => false, :rate => 4000.0)

    Factory(:fact, :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
      :amount => 100, :from => purchase_n33,
      :to => sale_n33, :resource => sale_n33.give)
    state = purchase_n33.state
    state.should_not be_nil, "Purchase state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(100 / purchase_n33.rate), "Wrong state amount"
    state = sale_n33.state
    state.should_not be_nil, "Sale state is nil"
    state.side.should eq(State::ACTIVE), "Wrong state side"
    state.amount.should eq(100 * sale_n33.rate), "Wrong state amount"

    sale_n33.rules.clear
    Factory(:rule, :deal => sale_n33, :from => bankaccount, :to => purchase_n33,
      :fact_side => true, :change_side => false)

    Factory(:fact, :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
      :amount => 200 * sale_n33.rate, :from => sale_n33,
      :to => bankaccount, :resource => sale_n33.take)
    state = purchase_n33.state
    state.should be_nil, "Purchase state is not nil"
    state = sale_n33.state
    state.should_not be_nil, "Sale state is nil"
    state.side.should eq(State::PASSIVE), "Wrong state side"
    state.amount.should eq(100), "Wrong state amount"

    alcatel = Factory(:asset)
    purchase_a = Factory(:deal, :rate => 0.0001, :entity => equipmentsupl,
      :give => rub, :take => alcatel)
    sale_a = Factory(:deal, :rate => 1000, :entity => buyer,
      :give => alcatel, :take => rub)

    Factory(:rule, :deal => purchase_a, :from => bankaccount, :to => purchase_a,
      :fact_side => true)

    Factory(:rule, :deal => sale_a, :from => sale_a, :to => bankaccount)

    Factory(:fact, :day => DateTime.civil(2011, 9, 4, 12, 0, 0), :amount => 100,
      :from => purchase_a, :to => sale_a, :resource => sale_a.give)
    state = purchase_a.state
    state.should be_nil, "Purchase state is not nil"
    state = sale_a.state
    state.should be_nil, "Sale state is not nil"
  end
end
