# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Quote < ActiveRecord::Base
  validates :money_id, :day, :rate, :diff, :presence => true
  validates_uniqueness_of :money_id, :scope => :day
  belongs_to :money
  after_initialize :do_initialize
  before_save :do_before_save

  private
  def do_initialize
    self.diff ||= 0.0 if self.attributes.has_key?('diff')
  end

  def do_before_save
    if !self.money.deal_gives.empty? and !self.money.quotes(:force_reload).empty?
      q = self.money.quote
      self.money.deal_gives.each do |deal|
        self.diff += (deal.balance.amount * (q.rate - self.rate)).accounting_norm
      end
    end
    true
  end
end
