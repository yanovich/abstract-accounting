# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Quote do
  it "quote" do
    Factory(:quote)
    should validate_presence_of :money_id
    should validate_presence_of :day
    should validate_presence_of :rate
    should validate_presence_of :diff
    should validate_uniqueness_of(:day).scoped_to(:money_id)
    should belong_to :money
    should have_many Quote.versions_association_name
    should have_many(:balances_as_give).through(:money).class_name(Balance)
    should have_many(:balances_as_take).through(:money).class_name(Balance)

    currency_test
  end

  def currency_test
    cf = Factory(:money)
    c1 = Factory(:money)
    c2 = Factory(:money)
    y = Factory(:asset)
    x = Factory(:asset)
    a2 = Factory(:deal, :give => c2, :take => c2)
    dy = Factory(:deal, :give => y, :take => y)
    bx1 = Factory(:deal, :give => c1, :take => x, :rate => (1.0 / 100.0))
    dx = Factory(:deal, :give => x, :take => x)
    sy2 = Factory(:deal, :give => y, :take => c2, :rate => 150.0)

    q = Factory(:quote, :money => c1, :rate => 1.5, :day => DateTime.civil(2008, 3, 24, 12, 0, 0))
    c1.quote.should eq(q)

    #purchase
    t = Txn.create!(:fact => Factory(:fact, :amount => 300.0,
                                        :day => DateTime.civil(2008, 3, 24, 12, 0, 0),
                                        :from => bx1, :to => dx, :resource => dx.give))
    t.value.should eq(45000.0)
    t.status.should eq(0)
    t.earnings.should eq(0.0)
    Balance.all.count.should eq(2)
    t.from_balance.amount.should eq(30000.0)
    t.from_balance.value.should eq(45000.0)
    t.from_balance.side.should eq(Balance::PASSIVE)
    t.to_balance.amount.should eq(300.0)
    t.to_balance.value.should eq(45000.0)
    t.to_balance.side.should eq(Balance::ACTIVE)

    #rate_change_before_income
    Income.all.should be_empty

    q = Factory(:quote, :money => c1, :rate => 1.6, :day => DateTime.civil(2008, 3, 25, 12, 0, 0))
    c1.quote.should eq(q)
    q.diff.should eq(-3000.0)

    Income.all.count.should eq(1)
    Income.open.count.should eq(1)
    Income.open.first.side.should eq(Income::PASSIVE)
    Income.open.first.value.should eq(q.diff)

    #sale_advance
    c2.quote.should be_nil
    Factory(:quote, :money => c2, :rate => 2.0, :day => DateTime.civil(2008, 3, 25, 12, 0, 0))

    t = Txn.create!(:fact => Factory(:fact, :amount => 60000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => sy2, :to => a2, :resource => a2.give))
    t.value.should eq(120000.0)
    t.status.should eq(0)
    t.earnings.should eq(0.0)
    t.from_balance.amount.should eq(400.0)
    t.from_balance.value.should eq(120000.0)
    t.from_balance.side.should eq(Balance::PASSIVE)
    t.to_balance.amount.should eq(60000.0)
    t.to_balance.value.should eq(120000.0)
    t.to_balance.side.should eq(Balance::ACTIVE)

    #forex_sale
    Factory(:quote, :money => cf, :rate => 1.0, :day => DateTime.civil(2008, 3, 24, 12, 0, 0))
    f1 = Factory(:deal, :give => c2, :take => cf, :rate => 2.1)
    t = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f1, :resource => f1.give))
    t.value.should eq(20000.0)
    t.status.should eq(1)
    t.earnings.should eq(1000.0)
    t.from_balance.amount.should eq(50000.0)
    t.from_balance.value.should eq(100000.0)
    t.from_balance.side.should eq(Balance::ACTIVE)
    t.to_balance.amount.should eq(21000.0)
    t.to_balance.value.should eq(21000.0)
    t.to_balance.side.should eq(Balance::ACTIVE)

    f2 = Factory(:deal, :give => c2, :take => cf, :rate => 2.0)
    t = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f2, :resource => f2.give))
    t.value.should eq(20000.0)
    t.status.should eq(0)
    t.earnings.should eq(0.0)
    t.from_balance.amount.should eq(40000.0)
    t.from_balance.value.should eq(80000.0)
    t.from_balance.side.should eq(Balance::ACTIVE)
    t.to_balance.amount.should eq(20000.0)
    t.to_balance.value.should eq(20000.0)
    t.to_balance.side.should eq(Balance::ACTIVE)

    f3 = Factory(:deal, :give => c2, :take => cf, :rate => 1.95)
    t = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f3, :resource => f3.give))
    t.value.should eq(20000.0)
    t.status.should eq(1)
    t.earnings.should eq(-500.0)
    t.from_balance.amount.should eq(30000.0)
    t.from_balance.value.should eq(60000.0)
    t.from_balance.side.should eq(Balance::ACTIVE)
    t.to_balance.amount.should eq(19500.0)
    t.to_balance.value.should eq(19500.0)
    t.to_balance.side.should eq(Balance::ACTIVE)

    #rate_change
    Income.all.count.should eq(1)
    income = Income.new Income.first.attributes

    q = Factory(:quote, :money => c2, :rate => 2.1, :day => DateTime.civil(2008, 3, 31, 12, 0, 0))
    c2.quote.should eq(q)
    q.diff.should eq(3000.0)

    Income.all.count.should eq(2)
    Income.first.start.should eq(income.start)
    Income.first.value.should eq(income.value)
    Income.first.side.should eq(income.side)
    Income.first.paid.should eq(DateTime.civil(2008, 3, 31, 12, 0, 0))
    Income.open.count.should eq(1)
    Income.open.first.side.should eq(Income::PASSIVE)
    Income.open.first.value.should eq(500.0)

    #forex_sale_after_rate_change
    f4 = Factory(:deal, :give => c2, :take => c1, :rate => (2.1 / 1.6))
    t = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 31, 12, 0, 0),
                                        :from => a2, :to => f4, :resource => f4.give))
    t.from_balance.amount.should eq(20000.0)
    t.from_balance.value.should eq(42000.0)
    t.from_balance.side.should eq(Balance::ACTIVE)
    t.to_balance.amount.should eq(13125.0)
    t.to_balance.value.should eq(21000.0)
    t.to_balance.side.should eq(Balance::ACTIVE)

    #transfer_rollback
    c3 = Factory(:money)
    by3 = Factory(:deal, :give => c3, :take => y, :rate => (1.0 / 200.0))
    Factory(:quote, :money => c3, :rate => 0.8, :day => DateTime.civil(2008, 4, 14, 12, 0, 0))
    f = Factory(:fact, :amount => 100.0, :day => DateTime.civil(2008, 4, 11, 12, 0, 0),
                       :from => by3, :to => dy, :resource => dy.give)

    Fact.all.count.should eq(7)
    State.open.count.should eq(10)

    f.destroy
    Fact.all.count.should eq(6)
    State.open.count.should eq(8)
  end
end
