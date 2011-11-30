# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Rule < ActiveRecord::Base
  has_paper_trail

  validates :deal_id, :from_id, :to_id, :rate, :presence => true
  validates_inclusion_of :fact_side, :in => [ true, false ]
  validates_inclusion_of :change_side, :in => [ true, false ]
  belongs_to :deal
  belongs_to :from, :class_name => "Deal"
  belongs_to :to, :class_name => "Deal"

  def to_fact
    Fact.new :from => self.from, :to => self.to,
             :amount => self.rate, :resource => self.to.give
  end
end
