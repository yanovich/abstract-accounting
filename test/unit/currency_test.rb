# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  def setup
    @c1 = Money.new :alpha_code => "c1", :num_code => 2
    @c1.save
    x = Asset.new :tag => "x"
    x.save
    @bx1 = Deal.new :tag => "bx1",
      :entity => Entity.new(:tag => "S1"),
      :give => @c1,
      :take => x,
      :rate => (1.0 / 100.0)
    @bx1.save
    @dx = Deal.new :tag => "dx",
      :entity => Entity.new(:tag => "K"),
      :give => x,
      :take => x,
      :rate => 1.0
    @dx.save
  end

  test "currency" do
    assert Quote.new(:money => @c1, :rate => 1.5,
      :day => DateTime.civil(2008, 3, 24, 12, 0, 0)).save, "Quote is not saved"
    purchase
  end

  private
  def purchase
    f = Fact.new(:amount => 300.0,
                :day => DateTime.civil(2008, 3, 24, 12, 0, 0),
                :from => @bx1,
                :to => @dx,
                :resource => @bx1.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 2, Balance.all.count, "Balance count is not equal to 2"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 30000.0, b.amount, "Wrong balance amount"
    assert_equal 45000.0, b.value, "Wrong balance value"
    assert_equal @bx1, b.deal, "Wrong balance deal"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 300.0, b.amount, "Wrong balance amount"
    assert_equal 45000.0, b.value, "Wrong balance value"
    assert_equal @dx, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
  end
end
