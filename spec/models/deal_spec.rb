# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Deal do
  it "should have next behaviour" do
    Factory(:deal)
    should validate_presence_of :tag
    should validate_presence_of :rate
    should validate_presence_of :entity_id
    should validate_presence_of :give_id
    should validate_presence_of :take_id
    should validate_uniqueness_of(:tag).scoped_to(:entity_id)
    should belong_to :entity
    should belong_to :give
    should belong_to :take
    should have_many(:states)
    should have_many(:balances)
    should have_many(:rules)

    deal_has_states
    deal_has_balances
  end

  def deal_has_states
    s = Factory(:state)
    s.should eq(s.deal.state(s.start)),
             "State from first deal is not equal saved state"
    s.deal.state(DateTime.now - 1).should be_nil, "State is not nil"
  end

  def deal_has_balances
    b = Factory(:balance)
    b.should eq(b.deal.balance),
             "Balance from first deal is not equal to saved balance"
  end
end
