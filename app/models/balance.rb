# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require "state_action"

class Balance < ActiveRecord::Base
  include StateAction

  validates :amount, :value, :start, :side, :deal_id, :presence => true
  validates_inclusion_of :side, :in => [PASSIVE, ACTIVE]
  validates_uniqueness_of :start, :scope => :deal_id
  belongs_to :deal
  after_initialize :do_init
  scope :open, where("balances.paid IS NULL")

  def update_value(side, amount, value)
    old_value = self.accounting_value
    old_amount = self.amount
    old_side = self.side
    if update_amount(side, amount)
      old_value *= -1 if old_side != self.side
      if side == PASSIVE && self.side == PASSIVE
        if has_credit?
          self.value = (self.amount * self.credit).accounting_norm
        elsif has_debit?
          self.value = (self.amount * self.deal.rate).accounting_norm
        else
          raise "Unexpected behaviour"
        end
      elsif side == ACTIVE && self.side == ACTIVE
        if has_debit?
          self.value = self.amount.accounting_norm
        elsif !value.accounting_zero?
          self.value = old_value + value
        else
          raise "Unexpected behaviour"
        end
      elsif side == PASSIVE && self.side == ACTIVE
        if has_debit?
          self.value = self.amount.accounting_norm
        else
          raise "Unexpected behaviour" \
            if old_value.accounting_negative? || old_amount.accounting_zero?
          self.value = (old_value * self.amount/old_amount).accounting_norm
        end
      elsif side == ACTIVE && self.side == ACTIVE
        if has_credit?
          self.value = self.amount
        elsif !old_value.accounting_negative? && !old_amount.accounting_zero?
          self.value = (old_value - self.amount/old_amount).accounting_norm
        else
          raise "Unexpected behaviour"
        end
      end
    end
    true
  end

  def accounting_value
    if Balance::ACTIVE == self.side && self.has_debit?
      return self.amount
    end
    self.value
  end

  protected
  def do_init
    self.side ||= ACTIVE if self.attributes.has_key?('side')
    self.amount ||= 0.0 if self.attributes.has_key?('amount')
    self.value ||= 0.0 if self.attributes.has_key?('value')
  end

  def has_debit?
    !Chart.first.nil? and self.deal.take == Chart.first.currency
  end

  def has_credit?
    return true if !Chart.first.nil? and self.deal.give == Chart.first.currency
    self.deal.give.is_a? Money and !self.deal.give.quotes.first.nil?
  end

  def credit
    if self.deal.give.is_a? Money and !self.deal.give.quotes.first.nil?
      return self.deal.give.quotes.first.rate
    elsif !Chart.first.nil? and self.deal.give == Chart.first.currency
      return 1.0
    end
    0.0
  end
end
