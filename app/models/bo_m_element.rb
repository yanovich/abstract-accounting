# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class BoMElement < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :resource_id, :bom_id, :rate
  belongs_to :resource, :class_name => "Asset"
  belongs_to :bom, :class_name => "BoM"

  def to_rule(deal, price, physical_volume)
    deal.rules.create!(:tag => "deal rule ##{deal.rules.count() + 1}",
                       :from => convertation_deal(deal.entity),
                       :to => money_storage(deal.entity),
                       :rate => self.rate * price.rate * physical_volume,
                       :fact_side => false, :change_side => true)
  end

  private
  def money_storage(entity)
    find_or_create_deal("storage from #{Chart.first.currency} to #{Chart.first.currency}",
                        entity, Chart.first.currency, Chart.first.currency, 1.0)
  end

  def convertation_deal(entity)
    find_or_create_deal("resource converter from #{resource.tag} to #{Chart.first.currency}",
                        entity, self.resource, Chart.first.currency, self.rate)
  end

  def find_or_create_deal(tag, entity, give, take, rate)
    deal = Deal.find_all_by_entity_id_and_give_id_and_take_id_and_give_type_and_take_type(
        entity, give, take, give.class, take.class).first
    deal = Deal.create!(:tag => tag, :rate => rate, :give => give, :take => take,
                        :entity => entity) if deal.nil?
    deal
  end
end
