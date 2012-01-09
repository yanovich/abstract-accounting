# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class EstimateElement < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :amount, :bom_id, :estimate_id
  validates_uniqueness_of :bom_id, :scope => :estimate_id
  belongs_to :bom, :class_name => "BoM"
  belongs_to :estimate

  def to_rule(deal)
    deal.rules.create!(:tag => "deal: #{deal.tag}; rule ##{deal.rules.count() + 1}",
                       :from => nil, :rate => 1.0, :fact_side => false, :change_side => true,
                       :to => self.bom.to_deal(deal.entity, self.estimate.price_list, 1))
  end
end
