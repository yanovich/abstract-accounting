# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Deal < ActiveRecord::Base
  validates_presence_of :tag
  validates_presence_of :rate
  belongs_to :entity
  belongs_to :give, :polymorphic => true
  belongs_to :take, :polymorphic => true
  has_many :states
  has_many :balances

  def state(day = nil)
    states.where(:start =>
      (unless day.nil?
        states.where("start <= ?", day)
      else
        states
      end).maximum("start")
    ).where("paid > ? OR paid is NULL", day).first
  end

  def balance
    balances.first
  end

  def update_by_fact(fact)
    return false if fact.nil?
    state = self.state
    state = self.states.build(:start => fact.day) if state.nil?
    if !state.new_record? && state.start < fact.day
      state_clone = self.states.build(state.attributes)
      return false unless state.update_attributes(:paid => fact.day)
      state = state_clone
      state.start = fact.day
    elsif !state.new_record? && state.start > fact.day
      raise "State start day is great then fact day"
    end
    return false unless state.update_amount(self.id == fact.from.id ? State::PASSIVE : State::ACTIVE, fact.amount)
    return state.destroy if state.zero? && !state.new_record?
    return true if state.zero? && state.new_record?
    state.save
  end

  def update_by_txn(txn)
    return false if txn.nil? or txn.fact.nil?
    balance = self.balance
    balance = self.balances.build :start => txn.fact.day if balance.nil?
    return false unless balance.update_value(self.id == txn.fact.from.id ? Balance::PASSIVE : Balance::ACTIVE,
                                              txn.fact.amount, txn.value)
    balance.save
  end
end

# vim: ts=2 sts=2 sw=2 et:
