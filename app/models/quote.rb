# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Quote < ActiveRecord::Base
  has_paper_trail

  validates :money_id, :day, :rate, :diff, :presence => true
  validates_uniqueness_of :day, :scope => :money_id
  belongs_to :money
  after_initialize :do_initialize
  before_save :do_before_save
  has_many :balances_as_give, :class_name => "Balance", :through => :money, :source => :balances_gives
  has_many :balances_as_take, :class_name => "Balance", :through => :money, :source => :balances_takes

  private
  def do_initialize
    self.diff ||= 0.0 if self.attributes.has_key?('diff')
  end

  def do_before_save
    if !self.balances_as_give.empty? and !self.money.quotes(:force_reload).empty?
      self.diff += (self.balances_as_give.not_paid.passive.sum("amount").to_f *
                    (self.money.quote.rate - self.rate)) .accounting_norm
    end
    if !self.balances_as_take.empty? and !self.money.quotes(:force_reload).empty?
      self.diff += (self.balances_as_take.not_paid.active.sum("amount").to_f *
                    (self.rate - self.money.quote.rate)) .accounting_norm
    end
    unless self.diff.accounting_zero?
      income = Income.open.first
      income = Income.new if income.nil?
      if !income.new_record? && income.start < self.day
        income_clone = Income.new income.attributes
        return false unless income.update_attributes(:paid => self.day)
        income = income_clone
      end
      income.quote = self
      return income.save
    end
    true
  end
end
