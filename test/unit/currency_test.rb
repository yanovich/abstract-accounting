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
    @cf = Money.new :alpha_code => "cf", :num_code => 1
    @cf.save
    @c1 = Money.new :alpha_code => "c1", :num_code => 2
    @c1.save
    @c2 = Money.new :alpha_code => "c2", :num_code => 3
    @c2.save
    x = Asset.new :tag => "x"
    x.save
    @B = Entity.new :tag => "B"
    @B.save
    @a2 = Deal.new :tag => "a2",
      :entity => @B,
      :give => @c2,
      :take => @c2,
      :rate => 1.0
    @a2.save
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
    @sy2 = Deal.new :tag => "sy2",
      :entity => Entity.new(:tag => "P2"),
      :give => Asset.new(:tag => "y"),
      :take => @c2,
      :rate => 150.0
    @sy2.save
  end

  test "currency" do
    assert Quote.new(:money => @c1, :rate => 1.5,
      :day => DateTime.civil(2008, 3, 24, 12, 0, 0)).save, "Quote is not saved"
    purchase
    rate_change_before_income
    sale_advance
    forex_sale
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

  def rate_change_before_income
    assert_equal Quote.first, @c1.quote, "Maximum quote for money is wrong"
    assert (q = Quote.new(:money => @c1, :rate => 1.6,
      :day => DateTime.civil(2008, 3, 25, 12, 0, 0))).save, "Quote is not saved"
    assert_equal q, @c1.quote, "Maximum quote for money is wrong"
    assert_equal -3000.0, q.diff, "Quote diff is wrong"

    assert_equal 1, Income.open.count, "Open incomes count is wrong"
    assert_equal Income::PASSIVE, Income.open.first.side, "Open income wrong side"
    assert_equal q.diff, Income.open.first.value, "Open income wrong value"
  end

  def sale_advance
    assert @c2.quote.nil?, "Money c2 quote is not nil"

    assert (Quote.new(:money => @c2, :rate => 2.0,
      :day => DateTime.civil(2008, 3, 25, 12, 0, 0))).save, "Quote is not saved"

    f = Fact.new(:amount => 60000.0,
                :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                :from => @sy2,
                :to => @a2,
                :resource => @sy2.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 400.0, b.amount, "Wrong balance amount"
    assert_equal 120000.0, b.value, "Wrong balance value"
    assert_equal @sy2, b.deal, "Wrong balance deal"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 60000.0, b.amount, "Wrong balance amount"
    assert_equal 120000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
  end

  def forex_sale
    assert (Quote.new :money => @cf, :rate => 1.0,
       :day => DateTime.civil(2008, 3, 24, 12, 0, 0)).save,
      "Quote is not saved"

    assert (f1 = Deal.new(:tag => "f1",
        :entity => @B, :give => @c2, :take => @cf, :rate => 2.1)).save,
      "Deal is not saved"

    f = Fact.new(:amount => 10000.0,
                :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                :from => @a2,
                :to => f1,
                :resource => @a2.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 50000.0, b.amount, "Wrong balance amount"
    assert_equal 100000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 21000.0, b.amount, "Wrong balance amount"
    assert_equal 21000.0, b.value, "Wrong balance value"
    assert_equal f1, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    assert (f2 = Deal.new(:tag => "f2",
        :entity => @B, :give => @c2, :take => @cf, :rate => 2.0)).save,
      "Deal is not saved"

    f = Fact.new(:amount => 10000.0,
                :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                :from => @a2,
                :to => f2,
                :resource => @a2.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 40000.0, b.amount, "Wrong balance amount"
    assert_equal 80000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 20000.0, b.amount, "Wrong balance amount"
    assert_equal 20000.0, b.value, "Wrong balance value"
    assert_equal f2, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    assert (f3 = Deal.new(:tag => "f3",
        :entity => @B, :give => @c2, :take => @cf, :rate => 1.95)).save,
      "Deal is not saved"

    f = Fact.new(:amount => 10000.0,
                :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                :from => @a2,
                :to => f3,
                :resource => @a2.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"

    b = t.from_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 30000.0, b.amount, "Wrong balance amount"
    assert_equal 60000.0, b.value, "Wrong balance value"
    assert_equal @a2, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    b = t.to_balance
    assert !b.nil?, "From balance is nil"
    assert_equal 19500.0, b.amount, "Wrong balance amount"
    assert_equal 19500.0, b.value, "Wrong balance value"
    assert_equal f3, b.deal, "Wrong balance deal"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
  end
end
