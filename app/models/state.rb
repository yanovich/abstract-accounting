# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class State < ActiveRecord::Base
  validates :amount, :start, :side, :deal_id, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"]
  belongs_to :deal

  after_initialize :do_init

  def resource
    return nil if self.deal.nil?
    return self.deal.take if self.side == "active"
    self.deal.give
  end

  def apply_fact(fact)
    return false if self.deal.nil?
    return false if fact.nil?
    true if set_fact_side(fact) and update_time(fact.day)
  end

  def zero?
    self.amount.accounting_zero?
  end

  private
  def do_init
    self.side ||= "active"
    self.amount ||= 0.0
  end

  def set_fact_side(fact)
    return false if fact.nil?
    fact_side =
      if self.deal.id == fact.from.id
        "passive"
      else
        "active"
      end
    if self.side != fact_side
      self.amount -= fact.amount
    else
      self.amount += fact.amount * deal_rate
    end
    if self.amount.accounting_negative?
      self.side =
        if self.side == "passive"
          "active"
        else
          "passive"
        end
      self.amount *= -1 * deal_rate
    end
    self.amount = self.amount.accounting_norm
    true
  end

  def deal_rate
    if self.side == "active"
      self.deal.rate
    else
      1/self.deal.rate
    end
  end

  def update_time(time)
    self.start = time
    true
  end
end
