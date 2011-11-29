# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Txn < ActiveRecord::Base
  has_paper_trail

  validates :value, :fact_id, :status, :presence => true
  validates_uniqueness_of :fact_id
  belongs_to :fact
  after_initialize :after_init
  before_save :before_save

  def from_balance
    self.fact.from.balance
  end

  def to_balance
    self.fact.to.balance
  end

  private
  def after_init
    self.value ||= 0.0 if self.attributes.has_key?('value')
    self.status ||= 0 if self.attributes.has_key?('status')
    self.earnings ||= 0.0 if self.attributes.has_key?('earnings')
  end

  def before_save
    unless self.fact.from.nil? || self.fact.from.income?
      balance = self.fact.from.balance
      old_balance_value = balance.nil? ? 0.0 : balance.accounting_value
      old_balance_side = balance.nil? ? Balance::ACTIVE : balance.side
      if self.fact.from.update_by_txn(self)
        balance = self.fact.from.balance
        old_balance_value *= -1 if !balance.nil? && old_balance_side != balance.side
        if balance.nil? || balance.side == Balance::ACTIVE
          self.value = old_balance_value - (balance.nil? ? 0.0 : balance.value)
        else
          self.value = balance.value - old_balance_value
        end
      else
        return false
      end
    end
    if self.fact.to.isOffBalance
      self.fact.children.each do |fact|
        return false unless Txn.new(:fact => fact).save
      end
      return true
    end
    if self.fact.to.income?
      self.earnings = -self.value
      self.status = 1
      income = Income.open.first
      income = Income.new if income.nil?
      income.txn = self
      return income.save
    else
      balance = self.fact.to.balance
      old_balance_value = balance.nil? ? 0.0 : balance.accounting_value
      old_balance_side = balance.nil? ? Balance::ACTIVE : balance.side
      if self.fact.to.update_by_txn(self)
        earnings_tmp = 0.0
        balance = self.fact.to.balance
        old_balance_value *= -1 if !balance.nil? && old_balance_side != balance.side
        if !balance.nil? && balance.side == Balance::ACTIVE
          earnings_tmp = balance.value - old_balance_value - self.value
        elsif balance.nil? && old_balance_side == Balance::PASSIVE
          earnings_tmp = old_balance_value - self.value
        end
        unless earnings_tmp.accounting_zero?
          self.status = 1
          self.earnings = earnings_tmp
          i = Income.open.first
          i = Income.new if i.nil?
          if !i.new_record? && i.start < self.fact.day
            i_clone = Income.new i.attributes
            return false unless i.update_attributes(:paid => self.fact.day)
            i = i_clone
          end
          i.txn = self
          return i.destroy if !i.new_record? && i.zero?
          return true if i.new_record? && i.zero?
          return i.save
        end
        return true
      end
    end
    false
  end
end
