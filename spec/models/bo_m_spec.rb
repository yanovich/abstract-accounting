# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe BoM do
  it "should have next behaviour" do
    should validate_presence_of(:resource_id)
    should validate_presence_of(:tab)
    should belong_to(:resource).class_name(Asset)
    should have_many(BoM.versions_association_name)
    should have_many(:items).class_name(BoMElement)
    should have_and_belong_to_many(:catalogs)
  end

  describe "#to_deal" do
    before(:all) do
      Factory(:chart)
      @entity = Factory(:entity)
      @truck = Factory(:asset)
      @compressor = Factory(:asset)
      @compaction = Factory(:asset)
      @prices = Factory(:price_list,
                        :resource => Factory(:asset,:tag => "TUP of the Leningrad region"),
                        :date => DateTime.civil(2011, 11, 01, 12, 0, 0))
      @prices.items.create!(:resource => @truck, :rate => (74.03 * 4.70))
      @prices.items.create!(:resource => @compressor, :rate => (59.76 * 4.70))
      @bom = Factory(:bo_m, :resource => @compaction)
      @bom.items.create!(:resource => @truck, :rate => 0.33)
      @bom.items.create!(:resource => @compressor,
                        :rate => 0.46)
    end

    it "should create deal with rules" do
      deal = nil
      lambda {
        deal = @bom.to_deal(@entity, @prices, 1)
      }.should change(Deal, :count).by(4)
      deal.should_not be_nil
      deal.entity.should eq(@entity)
      deal.give.should eq(@compaction)
      deal.take.should eq(@compaction)
      deal.rate.should eq(1.00)
      deal.isOffBalance.should be_true
      deal.rules.count.should eq(2)
      [deal.rules.first.from.give, deal.rules.last.from.give].should =~ [@compressor, @truck]
      deal.rules.each do |rule|
        if rule.from.give == @truck
          rule.rate.should eq(0.33 * (74.03 * 4.70))
          rule.from.rate.should eq(0.33)
        elsif rule.from.give == @compressor
          rule.rate.should eq(0.46 * (59.76 * 4.70))
          rule.from.rate.should eq(0.46)
        end
      end
    end

    it "should create different deal for same entity and bom" do
      @bom.to_deal(@entity, @prices, 1).should_not be_nil
    end

    it "should resend physical volume to rule creation" do
      deal = @bom.to_deal(@entity, @prices, 2)
      deal.rules.count.should eq(2)
      [deal.rules.first.from.give, deal.rules.last.from.give].should =~ [@compressor, @truck]
      deal.rules.each do |rule|
        if rule.from.give == @truck
          rule.rate.should eq(0.33 * (74.03 * 4.70) * 2)
          rule.from.rate.should eq(0.33)
        elsif rule.from.give == @compressor
          rule.rate.should eq(0.46 * (59.76 * 4.70) * 2)
          rule.from.rate.should eq(0.46)
        end
      end
    end
  end

  it "should return sum by bom" do
    truck = Factory(:asset)
    compressor = Factory(:asset)
    compaction = Factory(:asset)
    prices = Factory(:price_list,
                      :resource => Factory(:asset,:tag => "TUP of the Leningrad region"),
                      :date => DateTime.civil(2011, 11, 01, 12, 0, 0))
    prices.items.create!(:resource => truck, :rate => (74.03 * 4.70))
    prices.items.create!(:resource => compressor, :rate => (59.76 * 4.70))
    bom = Factory(:bo_m, :resource => compaction)
    bom.items.create!(:resource => truck, :rate => 0.33)
    bom.items.create!(:resource => compressor,
                      :rate => 0.46)
    bom.sum(prices, 1).should eq((0.33 * (74.03 * 4.70)) + (0.46 * (59.76 * 4.70)))
    bom.sum(prices, 2).should eq(((0.33 * (74.03 * 4.70)) + (0.46 * (59.76 * 4.70))) * 2)
    catalog = Catalog.create!(tag: "some catalog")
    catalog.price_lists << prices
    bom.sum_by_catalog(catalog, prices.date, 2).should eq(
           ((0.33 * (74.03 * 4.70)) + (0.46 * (59.76 * 4.70))) * 2)
  end
end
