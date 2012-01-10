# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Estimate < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :entity_id, :price_list_id
  belongs_to :entity
  belongs_to :price_list
  belongs_to :deal
  has_many :items, :class_name => "EstimateElement",
           :after_remove => :remove_item,
           :before_add => :add_item

  private
  def remove_item(element)
    self.deal.rules.each do |rule|
      self.deal.rules.delete(rule.destroy) if rule.to.give == element.bom.resource
    end
  end

  def add_item(element)
    unless self.deal
      estimate_shipment = Asset.find_or_create_by_tag("Estimate shipment")
      self.create_deal!(
        :tag => "estimate deal ##{
          Deal.find_all_by_entity_id(self.entity).count + 1
        } for entity #{self.entity.tag}", :isOffBalance => true,
        :give => estimate_shipment, :take => estimate_shipment,
        :rate => 1.0, :entity => self.entity
      )
    end
    element.to_rule(self.deal, self.price_list)
  end
end
