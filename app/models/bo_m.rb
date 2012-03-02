# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class BoM < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :resource_id, :tab
  belongs_to :resource, :class_name => 'Asset'
  has_many :items, :class_name => "BoMElement", :foreign_key => :bom_id
  has_and_belongs_to_many :catalogs

  def sum(prices, physical_amount)
    self.items.reduce(0) do |sum, item|
      sum + item.sum(prices.items.where(resource_id: item.resource_id).first,
          physical_amount)
    end
  end

  def sum_by_catalog(catalog, date, physical_amount)
    self.sum(catalog.price_list(date, self.tab), physical_amount)
  end

  def to_deal(entity, prices, physical_amount)
    deal = Deal.create!(:tag => "estimate deal for bom: #{self.id}; ##{
      Deal.where("tag LIKE 'estimate deal for bom: #{self.id}; #%'").count() + 1
    }",
                        :entity => entity, :give => self.resource, :take => self.resource,
                        :rate => 1.0, :isOffBalance => true)
    self.items.each do |element|
      price = prices.items.where("resource_id = ?", element.resource_id).first
      element.to_rule(deal, price, physical_amount)
    end
    deal
  end
end
