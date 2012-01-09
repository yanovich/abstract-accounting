# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe EstimateElement do
  it "should have next behaviour" do
    EstimateElement.create!(:estimate_id => 0, :bom_id => 0, :amount => 10)
    should validate_presence_of :estimate_id
    should validate_presence_of :bom_id
    should validate_presence_of :amount
    should validate_uniqueness_of(:bom_id).scoped_to(:estimate_id)
    should belong_to :estimate
    should belong_to(:bom).class_name(BoM)
    should have_many EstimateElement.versions_association_name
  end

  it "should convert self to rule" do
    Factory(:chart)
    entity = Factory(:entity)
    truck = Factory(:asset)
    compressor = Factory(:asset)
    compaction = Factory(:asset)
    prices = PriceList.create!(
        :resource => Factory(:asset,:tag => "TUP of the Leningrad region"),
        :date => DateTime.civil(2011, 11, 01, 12, 0, 0))
    prices.items.create!(:resource => truck, :rate => (74.03 * 4.70))
    prices.items.create!(:resource => compressor, :rate => (59.76 * 4.70))
    bom = BoM.create!(:resource => compaction)
    bom.items.create!(:resource => truck, :rate => 0.33)
    bom.items.create!(:resource => compressor,
                      :rate => 0.46)
    estimate = Estimate.create!(:entity => entity, :price_list => prices, :deal_id => 1)
    deal = Factory(:deal)
    rule = nil
    lambda {
      rule = estimate.items.create!(:bom => bom, :amount => 10).to_rule(deal)
    }.should change(deal.rules, :count).by(1)
    rule.from.should be_nil
    rule.to.should_not be_nil
    rule.rate.should eq(1.0)
    rule.deal_id.should eq(deal.id)
    rule.to.give.should eq(bom.resource)
    rule.to.rules.count.should eq(2)
  end
end
