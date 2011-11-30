# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Deal < ActiveRecord::Base
  has_paper_trail

  validates :tag, :rate, :entity_id, :give_id, :take_id, :presence => true
  validates_uniqueness_of :tag, :scope => :entity_id
  belongs_to :entity
  belongs_to :give, :polymorphic => true
  belongs_to :take, :polymorphic => true
  has_many :states
  has_many :balances
  has_many :rules

  def self.income
    income = Deal.where(:id => INCOME_ID).first
    if income.nil?
      income = Deal.new :tag => "profit and loss", :rate => 1.0
      income.id = INCOME_ID
    end
    income
  end

  def income?
    self.id == INCOME_ID
  end

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
    balances.where("balances.paid IS NULL").first
  end

  def update_by_fact(fact)
    return false if fact.nil?
    return true if self.income?
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
    return false unless state.update_amount(self.id == fact.from_deal_id ? State::PASSIVE : State::ACTIVE, fact.amount)
    return state.destroy if state.zero? && !state.new_record?
    return true if state.zero? && state.new_record?
    state.save
  end

  def update_by_txn(txn)
    return false if txn.nil? or txn.fact.nil?
    return true if self.income?
    balance = self.balance
    balance = self.balances.build :start => txn.fact.day if balance.nil?
    if !balance.new_record? && balance.start < txn.fact.day
      balance_clone = self.balances.build(balance.attributes)
      return false unless balance.update_attributes(:paid => txn.fact.day)
      balance = balance_clone
      balance.start = txn.fact.day
    elsif !balance.new_record? && balance.start > txn.fact.day
      raise "Balance start day is greater then fact day"
    end
    return false unless balance.update_value(self.id == txn.fact.from.id ? Balance::PASSIVE : Balance::ACTIVE,
                                              txn.fact.amount, txn.value)
    return balance.destroy if balance.zero? && !balance.new_record?
    return true if balance.zero? && balance.new_record?
    balance.save
  end

  def balances_by_time_frame(start, stop)
    self.balances.where("balances.start < :stop AND (balances.paid > :start OR balances.paid IS NULL)",
                        :start => DateTime.civil(start.year, start.month, start.day, 0, 0, 0),
                        :stop => DateTime.civil(stop.year, stop.month, stop.day, 13, 0, 0)).all
  end

  def facts(start, stop)
    if self.income?
      Fact
    else
      Fact.where("(facts.from_deal_id = :id OR facts.to_deal_id = :id)",
                  :id => self.id)
    end.where("facts.day > :start AND facts.day < :stop",
              :start => DateTime.civil(start.year, start.month, start.day, 0, 0, 0),
              :stop => DateTime.civil(stop.year, stop.month, stop.day, 13, 0, 0)).all
  end

  def txns(start, stop)
    if self.income?
      Txn.find_all_by_fact_id_and_status(self.facts(start, stop), 1)
    else
      Txn.find_all_by_fact_id(self.facts(start, stop))
    end
  end

  private
  INCOME_ID = 0
end

# vim: ts=2 sts=2 sw=2 et:
