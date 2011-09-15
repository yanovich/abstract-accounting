# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class State < ActiveRecord::Base
  PASSIVE = "passive"
  ACTIVE = "active"

  validates :amount, :start, :side, :deal_id, :presence => true
  validates_inclusion_of :side, :in => [PASSIVE, ACTIVE]
  belongs_to :deal

  after_initialize :do_init

  def resource
    return nil if self.deal.nil?
    self.side == ACTIVE ? self.deal.take : self.deal.give
  end

  def update_amount(side, amount)
    return false if self.deal.nil?
    if self.side != side
      self.amount -= amount
    else
      self.amount += amount * rate
    end
    if self.amount.accounting_negative?
      self.side =
        if self.side == "passive"
          "active"
        else
          "passive"
        end
      self.amount *= -1 * rate
    end
    self.amount = self.amount.accounting_norm
    true
  end

  def zero?
    self.amount.accounting_zero?
  end

  private
  def do_init
    self.side ||= ACTIVE
    self.amount ||= 0.0
  end

  def rate
    if self.side == ACTIVE
      self.deal.rate
    else
      1/self.deal.rate
    end
  end
end
