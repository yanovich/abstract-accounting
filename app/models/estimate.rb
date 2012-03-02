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

  validates_presence_of :legal_entity_id, :catalog_id, :date
  belongs_to :legal_entity
  belongs_to :catalog
  belongs_to :deal
  has_many :items, :class_name => "EstimateElement",
           :after_remove => :remove_item,
           :before_add => :add_item

  def price_list(bom)
    self.catalog.price_list(self.date, bom.tab)
  end

  private
  def remove_item(element)
    self.deal.rules.each do |rule|
      self.deal.rules.delete(rule.destroy) if rule.to.give == element.bom.resource
    end
    (self.deal.destroy && self.update_attributes(:deal_id => nil)) if self.deal.rules.empty?
  end

  def add_item(element)
    unless self.deal
      estimate_shipment = Asset.find_or_create_by_tag("Estimate shipment")
      self.create_deal!(
        :tag => "estimate deal ##{
          Deal.find_all_by_entity_id_and_entity_type(self.legal_entity.id,
                                                     LegalEntity).count + 1
        } for entity #{self.legal_entity.name}", :isOffBalance => true,
        :give => estimate_shipment, :take => estimate_shipment,
        :rate => 1.0,
        :entity => self.legal_entity
      )
      self.save!
    end
    element.to_rule(self.deal, self.price_list(element.bom))
  end
end
