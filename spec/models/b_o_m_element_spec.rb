# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe BoMElement do
  it "should have next behaviour" do
    should validate_presence_of :resource_id
    should validate_presence_of :bom_id
    should validate_presence_of :rate
    should belong_to(:resource).class_name(Asset)
    should belong_to(:bom).class_name(BoM)
    should have_many(BoMElement.versions_association_name)
  end

  describe "#to_rule" do
    before(:all) do
      @chart = Factory(:chart)
      @bom_deal = Factory(:deal)
    end

    it "should create rule" do
      resource = Factory(:asset, :tag => "Avtopogruzchik 5t")
      price = Factory(:price, :resource => resource, :rate => (74.03 * 4.70))
      element = Factory(:bo_m_element, :resource => resource, :rate => 0.33)
      lambda {
        element.to_rule(@bom_deal, price)
      }.should change(@bom_deal.rules, :count).by(1)
      rule = @bom_deal.rules.first
      rule.rate.should eq(0.33 * (74.03 * 4.70))
      rule.deal_id.should eq(@bom_deal.id)
      rule.from.rate.should eq(0.33)
      rule.from.give.should eq(resource)
      rule.from.take.should eq(@chart.currency)
      rule.from.entity.should eq(@bom_deal.entity)
      rule.to.rate.should eq(1.0)
      rule.to.give.should eq(@chart.currency)
      rule.to.take.should eq(@chart.currency)
      rule.to.entity.should eq(@bom_deal.entity)
    end

    it "should use same deal for money storage in rule" do
      resource = Factory(:asset, :tag => "Rompressory peredvignie")
      price = Factory(:price, :resource => resource, :rate => (59.76 * 4.70))
      element = Factory(:bo_m_element, :resource => resource, :rate => 0.46)
      lambda {
        element.to_rule(@bom_deal, price)
      }.should change(Deal, :count).by(1)
      rule = @bom_deal.rules.last
      rule.rate.should eq(0.46 * (59.76 * 4.70))
      rule.deal_id.should eq(@bom_deal.id)
      rule.from.rate.should eq(0.46)
      rule.from.give.should eq(resource)
      rule.from.take.should eq(@chart.currency)
      rule.from.entity.should eq(@bom_deal.entity)
      rule.to.should eq(@bom_deal.rules.first.to)
    end
  end
end
