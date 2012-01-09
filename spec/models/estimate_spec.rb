# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Estimate do
  it "should have next behaviour" do
    should validate_presence_of :entity_id
    should validate_presence_of :price_list_id
    should belong_to(:deal)
    should belong_to(:entity)
    should belong_to(:price_list)
    should have_many Estimate.versions_association_name
    should have_many(:items).class_name(EstimateElement)
  end

  it "should create deal before save by items" do
    Factory(:chart)
    entity = Factory(:entity)
    truck = Factory(:asset)
    truck2 = Factory(:asset)
    compressor = Factory(:asset)
    compaction = Factory(:asset)
    covering = Factory(:asset)
    prices = PriceList.create!(
        :resource => Factory(:asset,:tag => "TUP of the Leningrad region"),
        :date => DateTime.civil(2011, 11, 01, 12, 0, 0))
    prices.items.create!(:resource => truck, :rate => (74.03 * 4.70))
    prices.items.create!(:resource => truck2, :rate => (74.03 * 6.06))
    prices.items.create!(:resource => compressor, :rate => (59.76 * 4.70))
    bom = BoM.create!(:resource => compaction)
    bom.items.create!(:resource => truck, :rate => 0.33)
    bom.items.create!(:resource => compressor,
                      :rate => 0.46)
    estimate = Estimate.new(:entity => entity, :price_list => prices)
    estimate.items.build(:bom => bom, :amount => 1.0)
    bom = BoM.create!(:resource => covering)
    bom.items.create!(:resource => truck2, :rate => 0.64)
    estimate.items.build(:bom => bom, :amount => 2.0)
    lambda {
      estimate.save!
    }.should change(Deal, :count).by(7)
    estimate.deal.entity.should eq(entity)
    estimate.deal.isOffBalance.should be_true
    estimate.deal.rules.count.should eq(2)
    [estimate.deal.rules.first.to.give,
     estimate.deal.rules.last.to.give].should =~ [compaction, covering]
  end
end
