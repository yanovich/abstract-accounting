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
  has_many :items, :class_name => "EstimateElement"

  before_save :do_before_save

  private
  def do_before_save
    unless self.deal_id
      give = Asset.find_or_create_by_tag("Estimate shipment")
      self.deal = Deal.create!(
          :tag => "estimate deal ##{
            Deal.find_all_by_entity_id(entity).count + 1
          } for entity #{entity.tag}", :isOffBalance => true,
          :give => give, :take => give, :rate => 1.0, :entity => self.entity)
      self.items.each do |item|
        item.to_rule(self.deal, self.price_list)
      end
    end
    true
  end
end
