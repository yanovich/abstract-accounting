# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Income < ActiveRecord::Base
  has_paper_trail

  PASSIVE = "passive"
  ACTIVE = "active"
  validates :start, :side, :value, :presence => true
  validates :start, :uniqueness => true
  validates :side, :inclusion => { :in => [PASSIVE, ACTIVE] }
  scope :open, where("incomes.paid IS NULL")
  after_initialize :do_initialize

  def self.find_all_by_time_frame(start, stop)
    where("incomes.start < :stop AND (incomes.paid > :start OR incomes.paid IS NULL)",
          :start => DateTime.civil(start.year, start.month, start.day, 0, 0, 0),
          :stop => DateTime.civil(stop.year, stop.month, stop.day, 13, 0, 0)).all
  end

  def debit_diff
    Quote.sum(:diff, :conditions => ["day = ? AND diff > 0.0", self.start])
  end

  def credit_diff
    Quote.sum(:diff, :conditions => ["day = ? AND diff < 0.0", self.start]) * -1
  end

  def zero?
    self.value.accounting_zero?
  end

  def txn=(txn)
    update_value(txn.fact.day, txn.earnings) if txn.status != 0
  end

  def quote=(quote)
    update_value(quote.day, quote.diff) unless quote.diff.accounting_zero?
  end

  private
  def do_initialize
    self.value ||= 0.0 if self.attributes.has_key?('value')
    self.side ||= PASSIVE if self.attributes.has_key?('side')
  end

  def update_value(day, value)
    self.start = day
    self.value += value
  end
end
