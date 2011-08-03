# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  test "rule must be saved" do
    r = Rule.new
    assert r.invalid?, "Empty rule valid"
    r.tag = "test rule"
    assert r.invalid?, "Rule should be invalid"
    r.deal = deals(:equityshare1)
    assert r.invalid?, "Rule should be invalid"
    r.rate = 1.0
    assert r.invalid?, "Rule should be invalid"
    r.change_side = true
    r.fact_side = false
    r.from = deals(:equityshare2)
    assert r.invalid?, "Rule should be invalid"
    r.to = deals(:bankaccount)
    assert r.valid?, "Rule is not valid"
    assert r.save, "Rule is not saved"
  end

  test "rule workflow" do
    x = Asset.new :tag => "resource x"
    assert x.save, "Asset is not saved"
    y = Asset.new :tag => "resource y"
    assert y.save, "Asset is not saved"
    keeper = Entity.new :tag => "keeper"
    assert keeper.save, "Entity is not saved"
    shipment = Asset.new :tag => "shipment"
    assert shipment.save, "Asset is not saved"
    supplier = Entity.new :tag => "supplier"
    assert supplier.save, "Entity is not saved"
    purchase_x = Deal.new :entity => supplier, :give => money(:rub),
      :take => x, :rate => (1.0 / 100.0), :tag => "purchase 1"
    assert purchase_x.save,"Dealisnot saved"
    purchase_y = Deal.new :entity => supplier, :give => money(:rub),
      :take => y, :rate => (1.0 / 150.0), :tag => "purchase 2"
    assert purchase_y.save, "Deal is not saved"
    storage_x = Deal.new :entity => keeper, :give => x,
      :take => x, :rate => 1.0, :tag => "storage 1"
    assert storage_x.save, "Deal is not saved"
    storage_y = Deal.new :entity => keeper, :give => y,
      :take => y, :rate => 1.0, :tag => "storage 2"
    assert storage_y.save, "Deal is not saved"
    sale_x = Deal.new :entity => supplier, :give => x,
      :take => money(:rub), :rate => 120.0, :tag => "sale 1"
    assert sale_x.save, "Deal is not saved"
    sale_y = Deal.new :entity => supplier, :give => y,
      :take => money(:rub), :rate => 160.0, :tag => "sale 2"
    assert sale_y.save, "Deal is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
                :from => purchase_x,
                :to => storage_x,
                :resource => purchase_x.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
                :from => purchase_y,
                :to => storage_y,
                :resource => purchase_y.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    assert_equal 4, Balance.open.count, "Wrong open balances count"
    b = purchase_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = purchase_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 7500.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = storage_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = storage_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    shipment_deal = Deal.new :tag => "shipment 1", :rate => 1.0,
      :entity => supplier, :give => shipment, :take => shipment,
      :isOffBalance => true
    assert shipment_deal.save, "Deal is not saved"
    assert_equal true, Deal.find(shipment_deal.id).isOffBalance,
      "Wrong saved value for is off balance"

    shipment_deal.rules.create :tag => "shipment1.rule1",
      :from => storage_x, :to => sale_x, :fact_side => false,
      :change_side => true, :rate => 27.0

    assert_equal 1, Rule.all.count, "Rule count is wrong"

    shipment_deal.rules.create :tag => "shipment1.rule2",
      :from => storage_y, :to => sale_y, :fact_side => false,
      :change_side => true, :rate => 42.0

    assert_equal 2, Rule.all.count, "Rule count is wrong"

    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2008, 9, 22, 12, 0, 0),
                :from => nil,
                :to => shipment_deal,
                :resource => shipment_deal.give)
    assert f.save, "Fact is not saved"

    assert_equal 7, State.open.count, "Wrong open states count"
    s = purchase_x.state
    assert !s.nil?, "State is nil"
    assert_equal 5000.0, s.amount, "State amount is wrong"

    s = purchase_y.state
    assert !s.nil?, "State is nil"
    assert_equal 7500.0, s.amount, "State amount is wrong"

    s = storage_x.state
    assert !s.nil?, "State is nil"
    assert_equal 23.0, s.amount, "State amount is wrong"

    s = storage_y.state
    assert !s.nil?, "State is nil"
    assert_equal 8.0, s.amount, "State amount is wrong"

    s = sale_x.state
    assert !s.nil?, "State is nil"
    assert_equal (120.0 * 27.0).accounting_norm, s.amount, "State amount is wrong"

    s = sale_y.state
    assert !s.nil?, "State is nil"
    assert_equal (160.0 * 42.0).accounting_norm, s.amount, "State amount is wrong"

    s = shipment_deal.state
    assert !s.nil?, "State is nil"
    assert_equal 1.0, s.amount, "State amount is wrong"

    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    assert_equal 4, Balance.open.count, "Wrong open balances count"
    b = purchase_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = purchase_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 7500.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = storage_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = storage_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
  end
end
