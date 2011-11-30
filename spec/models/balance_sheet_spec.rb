# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe BalanceSheet do
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
    Txn.create!(:fact => Factory(:fact, :amount => 300.0,
                                        :day => DateTime.civil(2008, 3, 24, 12, 0, 0),
                                        :from => bx1, :to => dx, :resource => dx.give))
    Factory(:quote, :money => c1, :rate => 1.6, :day => DateTime.civil(2008, 3, 25, 12, 0, 0))
    Factory(:quote, :money => c2, :rate => 2.0, :day => DateTime.civil(2008, 3, 25, 12, 0, 0))
    Txn.create!(:fact => Factory(:fact, :amount => 60000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => sy2, :to => a2, :resource => a2.give))
    Factory(:quote, :money => cf, :rate => 1.0, :day => DateTime.civil(2008, 3, 24, 12, 0, 0))
    f1 = Factory(:deal, :give => c2, :take => cf, :rate => 2.1)
    Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f1, :resource => f1.give))
    f2 = Factory(:deal, :give => c2, :take => cf, :rate => 2.0)
    Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f2, :resource => f2.give))
    f3 = Factory(:deal, :give => c2, :take => cf, :rate => 1.95)
    Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 25, 12, 0, 0),
                                        :from => a2, :to => f3, :resource => f3.give))
    Factory(:quote, :money => c2, :rate => 2.1, :day => DateTime.civil(2008, 3, 31, 12, 0, 0))
    f4 = Factory(:deal, :give => c2, :take => c1, :rate => (2.1 / 1.6))
    Txn.create!(:fact => Factory(:fact, :amount => 10000.0,
                                        :day => DateTime.civil(2008, 3, 31, 12, 0, 0),
                                        :from => a2, :to => f4, :resource => f4.give))

    bs = Balance.find_all_by_time_frame DateTime.now, DateTime.now
    bs.count.should eq(8)
    (bs + Income.find_all_by_time_frame(DateTime.now, DateTime.now)).count.should eq(9)

    dt = DateTime.now
    dt.should eq(BalanceSheet.new(dt).date)

    bs = BalanceSheet.new
    bs.count.should eq(9)
    bs.last.value.should eq(500.0)
    bs.last.side.should eq(Income::PASSIVE)
    bs.assets.should eq(165500.0)
    bs.liabilities.should eq(168500.0)

    bs = BalanceSheet.new DateTime.civil(2008, 3, 25, 12, 0, 0)
    bs.count.should eq(8)
    bs.assets.should eq(162500.0)
    bs.liabilities.should eq(165500.0)
    bs.to_a.should =~ (Balance.find_all_by_time_frame(DateTime.civil(2008, 3, 26, 12, 0, 0),
                                                     DateTime.civil(2008, 3, 25, 12, 0, 0)) +
                      Income.find_all_by_time_frame(DateTime.civil(2008, 3, 26, 12, 0, 0),
                                                     DateTime.civil(2008, 3, 25, 12, 0, 0)))
  end
end
