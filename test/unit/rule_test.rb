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
  end
end
