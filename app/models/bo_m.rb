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

  def to_deal(entity, prices, physical_volume)
    deal = Deal.create!(:tag => "estimate deal for bom: #{self.id}; ##{
      Deal.where("tag LIKE 'estimate deal for bom: #{self.id}; #%'").count() + 1
    }",
                        :entity => entity, :give => self.resource, :take => self.resource,
                        :rate => 1.0, :isOffBalance => true)
    self.items.each do |element|
      price = prices.items.where("resource_id = ?", element.resource_id).first
      element.to_rule(deal, price, physical_volume)
    end
    deal
  end
end
