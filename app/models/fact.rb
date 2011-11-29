# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class FactValidator < ActiveModel::Validator
  def validate(record)
    return if record.from.nil? and record.to.nil?
    record.errors[:base] << "bad resource" unless
        (record.from.nil? and !record.to.nil?) or
        ((record.resource == record.from.take || record.from.income?) \
        and (record.resource == record.to.give || record.to.income?))
  end
end

class Fact < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :amount
  validates_presence_of :resource_id
  validates_presence_of :to_deal_id
  validates_with FactValidator
  belongs_to :resource, :polymorphic => true
  belongs_to :from, :class_name => "Deal", :foreign_key => "from_deal_id"
  belongs_to :to, :class_name => "Deal", :foreign_key => "to_deal_id"
  has_one :txn
  after_initialize :do_after_initialize
  before_save :do_save
  before_destroy :do_before_destroy

  scope :pendings, includes("txn").where("txns.id is NULL")

  def children
    @children
  end

  private
  def do_after_initialize
    @children = Array.new
  end

  def do_save
    if changed? or new_record?
      unless self.from.nil?
        return false unless update_states(self.from)
      end
      update_states(self.to)
    end
  end

  def do_before_destroy
    self.amount = -self.amount
    return false unless self.from.update_by_fact(self)
    self.to.update_by_fact(self)
  end

  def update_states(deal)
    state = deal.state
    side = state.nil? ? State::ACTIVE : state.side
    old_amount = state.nil? ? 0.0 : state.amount
    if deal.update_by_fact(self)
      state = deal.state
      new_side = state.nil? ? State::ACTIVE : state.side
      new_amount = state.nil? ? 0.0 : state.amount
      deal.rules(:force).each do |rule|
        if rule.fact_side ? from_deal_id == deal.id : to_deal_id == deal.id
          amount = 0.0
          if rule.change_side
            if from_deal_id == deal.id ? State::PASSIVE == side : State::ACTIVE == side
              amount = self.amount * (side == State::ACTIVE ? deal.rate : (1 / deal.rate).accounting_norm)
            end
            amount = new_amount if new_side != side
          else
            amount = self.amount if from_deal_id == deal.id ? State::PASSIVE != side : State::ACTIVE != side
            amount = old_amount if new_side != side
          end
          unless amount.accounting_zero?
            fact = rule.to_fact
            fact.day = self.day
            fact.amount *= amount
            @children << fact
            return false unless fact.save
          end
        end
      end
      return true
    end
    false
  end
end
