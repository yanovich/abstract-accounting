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
    should validate_presence_of :legal_entity_id
    should validate_presence_of :price_list_id
    should belong_to(:deal)
    should belong_to(:legal_entity)
    should belong_to(:price_list)
    should have_many Estimate.versions_association_name
    should have_many(:items).class_name(EstimateElement)
  end

  describe "#items" do
    before(:all) do
      Factory(:chart)
      @truck = Factory(:asset)
      @truck2 = Factory(:asset)
      @compressor = Factory(:asset)
      @compaction = Factory(:asset)
      @covering = Factory(:asset)
      prices = Factory(:price_list,
                       :resource => Factory(:asset,:tag => "TUP of the Leningrad region"),
                       :date => DateTime.civil(2011, 11, 01, 12, 0, 0))
      prices.items.create!(:resource => @truck, :rate => (74.03 * 4.70))
      prices.items.create!(:resource => @truck2, :rate => (74.03 * 6.06))
      prices.items.create!(:resource => @compressor, :rate => (59.76 * 4.70))
      @estimate = Estimate.create!(:legal_entity => Factory(:legal_entity),
                                   :price_list => prices)
    end

    it "should create deal when first item added" do
      @estimate.deal.should be_nil
      bom = Factory(:bo_m, :resource => @compaction)
      bom.items.create!(:resource => @truck, :rate => 0.33)
      bom.items.create!(:resource => @compressor,
                        :rate => 0.46)
      @estimate.items.create!(:bom => bom, :amount => 1.0)
      @estimate.deal.entity.should eq(Entity.where(:tag => @estimate.legal_entity.name).
                                          first_or_create!)
      @estimate.deal.isOffBalance.should be_true
      Estimate.find(@estimate).deal.should eq(@estimate.deal)
    end

    it "should create rules when item added" do
      @estimate.deal.rules.count.should eq(1)
      @estimate.deal.rules.first.to.give.should eq(@compaction)
      bom = Factory(:bo_m, :resource => @covering)
      bom.items.create!(:resource => @truck2, :rate => 0.64)
      @estimate.items.build(:bom => bom, :amount => 2.0)
      @estimate.deal.rules.count.should eq(2)
      [@estimate.deal.rules.first.to.give,
      @estimate.deal.rules.last.to.give].should =~ [@compaction, @covering]
    end

    it "should remove rules from deal when item removed" do
      @estimate.deal.rules.count.should eq(2)
      lambda {
        @estimate.items.delete(@estimate.items.last.destroy)
      }.should change(Rule, :count).by(-1)
      @estimate.deal.rules.count.should eq(1)
      @estimate.deal.rules.first.to.give.should eq(@estimate.items.first.bom.resource)
    end

    it "should remove deal when item removed and items.count = 0" do
      @estimate.deal.rules.count.should eq(1)
      lambda {
        @estimate.items.delete(@estimate.items.last.destroy)
      }.should change(Deal, :count).by(-1)
      @estimate.deal.should be_nil
      Estimate.find(@estimate.id).deal.should be_nil
    end
  end
end
