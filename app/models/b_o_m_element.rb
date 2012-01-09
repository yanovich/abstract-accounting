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

  def to_rule(deal, price)
    from = Deal.create!(
                 :tag => "resource converter from #{resource.tag} to #{Chart.first.currency}",
                 :rate => self.rate, :give => self.resource, :take => Chart.first.currency,
                 :entity => deal.entity)
    to = Deal.create!(
                 :tag => "storage from #{Chart.first.currency} to #{Chart.first.currency}",
                 :rate => 1.0, :give => Chart.first.currency, :take => Chart.first.currency,
                 :entity => deal.entity)
    deal.rules.create!(:tag => "deal rule ##{deal.rules.count() + 1}",
                       :from => from, :to => to, :rate => self.rate * price.rate,
                       :fact_side => false, :change_side => true)
  end
end
