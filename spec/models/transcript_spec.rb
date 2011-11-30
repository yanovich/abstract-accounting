# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Transcript do
  it "should have next behaviour" do
    cf = Factory(:money)
    c1 = Factory(:money)
    c2 = Factory(:money)
    y = Factory(:asset)
    x = Factory(:asset)
    a2 = Factory(:deal, :give => c2, :take => c2)
    bx1 = Factory(:deal, :give => c1, :take => x, :rate => (1.0 / 100.0))
    dx = Factory(:deal, :give => x, :take => x)
    sy2 = Factory(:deal, :give => y, :take => c2, :rate => 150.0)
    Factory(:quote, :money => c1, :rate => 1.5, :day => DateTime.civil(2008, 3, 24, 12, 0, 0))
    t1 = Txn.create!(:fact => Factory(:fact, :amount => 300.0,
                                        :day => DateTime.civil(2008, 3, 24, 12, 0, 0),
                                        :from => bx1, :to => dx, :resource => dx.give))
    Factory(:quote, :money => c1, :rate => 1.6, :day => DateTime.civil(2008, 3, 25, 12, 0, 0))
    Factory(:quote, :money => c2, :rate => 2.0, :day => DateTime.civil(2008, 3, 25, 12, 0, 0))
    t2 = Txn.create!(:fact => Factory(:fact, :amount => 60000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => sy2, :to => a2, :resource => a2.give))
    Factory(:quote, :money => cf, :rate => 1.0, :day => DateTime.civil(2008, 3, 24, 12, 0, 0))
    f1 = Factory(:deal, :give => c2, :take => cf, :rate => 2.1)
    t3 = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f1, :resource => f1.give))
    f2 = Factory(:deal, :give => c2, :take => cf, :rate => 2.0)
    t4 = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f2, :resource => f2.give))
    f3 = Factory(:deal, :give => c2, :take => cf, :rate => 1.95)
    t5 = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f3, :resource => f3.give))
    Factory(:quote, :money => c2, :rate => 2.1, :day => DateTime.civil(2008, 3, 31, 12, 0, 0))
    f4 = Factory(:deal, :give => c2, :take => c1, :rate => (2.1 / 1.6))
    t6 = Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 31, 12, 0, 0),
                                        :from => a2, :to => f4, :resource => f4.give))

    txns = a2.txns(DateTime.civil(2008, 3, 25, 12, 0, 0), DateTime.civil(2008, 3, 25, 12, 0, 0))
    txns.count.should eq(4)
    txns.each { |txn| txn.should be_kind_of(Txn); [txn.fact.from, txn.fact.to].should include(a2) }
    txns = a2.txns(DateTime.civil(2008, 3, 25, 12, 0, 0), DateTime.civil(2008, 3, 31, 12, 0, 0))
    txns.count.should eq(5)
    txns.each { |txn| txn.should be_kind_of(Txn); [txn.fact.from, txn.fact.to].should include(a2) }

    balances = a2.balances_by_time_frame(DateTime.civil(2008, 3, 25, 12, 0, 0),
                                          DateTime.civil(2008, 3, 25, 12, 0, 0))
    balances.count.should eq(1)
    balances.first.start.should eq(DateTime.civil(2008, 3, 25, 12, 0, 0))
    balances.first.paid.should eq(DateTime.civil(2008, 3, 31, 12, 0, 0))

    tr = Transcript.new(a2, DateTime.civil(2008, 3, 25, 12, 0, 0), DateTime.civil(2008, 3, 25, 12, 0, 0))
    tr.deal.should eq(a2)
    tr.start.should eq(DateTime.civil(2008, 3, 25, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2008, 3, 25, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(60000.0 - 10000.0 - 10000.0 - 10000.0)
    tr.closing.value.should eq(60000.0)
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(4)
    tr.to_a.should =~ [t2, t3, t4, t5]

    tr = Transcript.new(a2, DateTime.civil(2008, 3, 25, 12, 0, 0), DateTime.civil(2008, 3, 31, 12, 0, 0))
    tr.deal.should eq(a2)
    tr.start.should eq(DateTime.civil(2008, 3, 25, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2008, 3, 31, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(60000.0 - 10000.0 - 10000.0 - 10000.0 - 10000.0)
    tr.closing.value.should eq(42000.0)
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(5)
    tr.to_a.should =~ [t2, t3, t4, t5, t6]
    tr.total_debits_diff.should eq(3000.0)
    tr.total_credits_diff.should eq(0.0)
    tr.total_debits.should eq(60000.0)
    tr.total_credits.should eq(40000.0)
    tr.total_debits_value.should eq(120000.0)
    tr.total_credits_value.should eq(81000.0)

    tr = Transcript.new(a2, DateTime.civil(2008, 3, 31, 12, 0, 0), DateTime.civil(2008, 3, 31, 12, 0, 0))
    tr.deal.should eq(a2)
    tr.start.should eq(DateTime.civil(2008, 3, 31, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2008, 3, 31, 12, 0, 0))

    tr.opening.amount.should eq(60000.0 - 10000.0 - 10000.0 - 10000.0)
    tr.opening.value.should eq(60000.0)
    tr.opening.side.should eq(Balance::ACTIVE)
    tr.closing.amount.should eq(60000.0 - 10000.0 - 10000.0 - 10000.0 - 10000.0)
    tr.closing.value.should eq(42000.0)
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(1)
    tr.to_a.should =~ [t6]

    tr = Transcript.new(a2, DateTime.civil(2008, 3, 20, 12, 0, 0), DateTime.civil(2008, 3, 20, 12, 0, 0))
    tr.deal.should eq(a2)
    tr.start.should eq(DateTime.civil(2008, 3, 20, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2008, 3, 20, 12, 0, 0))
    tr.opening.should be_nil
    tr.closing.should be_nil
    tr.should be_empty

    tr = Transcript.new(bx1, DateTime.civil(2008, 3, 24, 12, 0, 0), DateTime.civil(2008, 3, 31, 12, 0, 0))
    tr.deal.should eq(bx1)
    tr.start.should eq(DateTime.civil(2008, 3, 24, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2008, 3, 31, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(30000.0)
    tr.closing.value.should eq(45000.0)
    tr.closing.side.should eq(Balance::PASSIVE)

    tr.count.should eq(1)
    tr.to_a.should =~ [t1]
    tr.total_debits_diff.should eq(0.0)
    tr.total_credits_diff.should eq(3000.0)
    tr.total_debits.should eq(0.0)
    tr.total_credits.should eq(300.0)
    tr.total_debits_value.should eq(0.0)
    tr.total_credits_value.should eq(45000.0)

    tr = Transcript.new(Deal.income, DateTime.civil(2008, 3, 24, 12, 0, 0), DateTime.civil(2008, 3, 31, 12, 0, 0))
    tr.deal.should eq(Deal.income)
    tr.start.should eq(DateTime.civil(2008, 3, 24, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2008, 3, 31, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.value.should eq(500.0)
    tr.closing.side.should eq(Balance::PASSIVE)

    tr.count.should eq(2)
    tr.to_a.should =~ [t3, t5]
    tr.total_debits_diff.should eq(3000.0)
    tr.total_credits_diff.should eq(3000.0)
    tr.total_debits_value.should eq(500.0)
    tr.total_credits_value.should eq(1000.0)
  end
end
