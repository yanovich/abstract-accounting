# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class FactValidator
  def validate(record)
    record.errors[:base] << "bad resource" unless
    record.resource == record.from.take \
    and record.resource == record.to.give
  end
end

class Fact < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :amount
  validates_presence_of :resource_id
  validates_presence_of :from_deal_id
  validates_presence_of :to_deal_id
  validates_with FactValidator
  belongs_to :resource, :polymorphic => true
  belongs_to :from, :class_name => "Deal", :foreign_key => "from_deal_id"
  belongs_to :to, :class_name => "Deal", :foreign_key => "to_deal_id"
  before_save :do_save

  private
  def do_save
    if changed? or new_record?
      return false unless init_state(self.from.state, self.from)
      return false unless init_state(self.to.state, self.to)
    end
  end

  def init_state(old_state, deal)
    return false if deal.nil?
    state =
      if old_state.nil?
        deal.states.build
      else
        old_state
      end
    if state.new_record?
      return state.save if state.apply_fact(self)
    elsif state.start == self.day
      if state.apply_fact(self)
        if state.zero?
          return state.destroy
        else
          return state.save
        end
      end
    else
      state.paid = self.day
      if state.save
        state2 = deal.states.build :start => self.day,
                                   :amount => state.amount,
                                   :side => state.side
        return state2.save if state2.apply_fact(self)
      end
    end
    false
  end
end
