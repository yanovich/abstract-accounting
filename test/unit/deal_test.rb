# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class DealTest < ActiveSupport::TestCase
  test "Deal should be stored" do
    d = Deal.new
    assert !d.save, "Empty deal saved"
    deal_entity = entities(:sergey)
    deal_take = money(:rub)
    deal_give = assets(:aasiishare)
    deal_tag = deals(:equityshare1).tag
    deal_rate = deals(:equityshare1).rate
    d = Deal.new
    d.tag = deal_tag
    d.rate = deal_rate
    d.entity = deal_entity
    d.give = deal_give
    d.take = deal_take
    assert_raise ActiveRecord::StatementInvalid do
      d.save!
    end
    d = deals(:equityshare1)
    assert_equal d, deal_entity.deals.where(:tag => deal_tag).first,
      "Entity deal is not equal to equityshare1"
    assert_equal d, deal_take.deal_takes.where(:tag => deal_tag).first,
      "Take resource not contain equityshare1"
    assert_equal d, deal_give.deal_gives.where(:tag => deal_tag).first,
      "Give resource not contain equityshare1"
  end

  test "Deal has states" do
    s = State.new
    s.deal = Deal.first
    assert s.invalid?, "State with deal is valid"
    s.start = DateTime.civil(2011, 1, 8)
    s.amount = 5000
    s.side = "active"
    assert s.save, "State is not saved"
    assert_equal s, Deal.first.state(s.start),
                 "State from first deal is not equal saved state"
    assert Deal.first.state(DateTime.civil(2011, 1, 7)).nil?,
           "State is not nil"
  end

  test "Deal has balances" do
    b = Deal.first.balances.build :start => DateTime.civil(2011, 1, 8),
                                  :amount => 5000,
                                  :value => 100,
                                  :side => Balance::ACTIVE
    assert b.valid?, "Balance is not valid"
    assert b.save, "Balance is not saved"
    assert_equal b, Deal.first.balance,
                 "Balance from first deal is not equal to saved balance"
  end
end

# vim: ts=2 sts=2 sw=2 et:
