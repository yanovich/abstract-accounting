# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class Bug133Test < ActiveSupport::TestCase
  test "bug133" do
    x = Money.new :alpha_code => "X", :num_code => 1
    assert x.save, "Money is not saved"
    y = Asset.new :tag => "y"
    assert y.save, "Asset is not saved"
    K = Entity.new :tag => "K"
    assert K.save, "Entity is not saved"
    L = Entity.new :tag => "L"
    assert L.save, "Entity is not saved"
    M = Entity.new :tag => "M"
    assert M.save, "Entity is not saved"
    N = Entity.new :tag => "N"
    assert N.save, "Entity is not saved"
    a = Deal.new :entity => K, :give => x, :take => y, :rate => (1.0 / 100.0),
      :tag => "a"
    assert a.save, "Deal is not saved"
    b = Deal.new :entity => L, :give => y, :take => y, :rate => 1.0,
      :tag => "b"
    assert b.save, "Deal is not saved"
    c = Deal.new :entity => M, :give => y, :take => x, :rate => 150.0,
      :tag => "c"
    assert c.save, "Deal is not saved"
    d = Deal.new :entity => N, :give => x, :take => x, :rate => 1.0,
      :tag => "d"
    assert d.save, "Deal is not saved"
    assert Quote.new(:money => x, :rate => 1.0,
      :day => DateTime.civil(2008, 2, 26, 12, 0, 0)).save,
      "Quote is not saved"
    f = Fact.new(:amount => 300.0,
                :day => DateTime.civil(2008, 2, 26, 12, 0, 0),
                :from => a,
                :to => b,
                :resource => a.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 200.0,
                :day => DateTime.civil(2008, 2, 26, 12, 0, 0),
                :from => b,
                :to => c,
                :resource => b.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 20000.0,
                :day => DateTime.civil(2008, 2, 26, 12, 0, 0),
                :from => c,
                :to => d,
                :resource => c.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    b = c.balance
    assert !b.nil?, "Balance is nil"

    assert_equal 10000.0, b.amount, "Wrong balance amount"
    assert_equal 10000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
  end
end
