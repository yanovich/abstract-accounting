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
    rub =  Factory(:chart).currency
    eur = Factory(:money)
    aasii = Factory(:asset)
    share2 = Factory(:deal, :give => aasii, :take => rub, :rate => 10000.0)
    share1 = Factory(:deal, :give => aasii, :take => rub, :rate => 10000.0)
    bank = Factory(:deal, :give => rub, :take => rub, :rate => 1.0)
    purchase = Factory(:deal, :give => rub, :rate => 0.0000142857143)
    bank2 = Factory(:deal, :give => eur, :take => eur, :rate => 1.0)
    forex1 = Factory(:deal, :give => rub, :take => eur, :rate => 0.028612303)
    forex2 = Factory(:deal, :give => eur, :take => rub, :rate => 35.0)

    Txn.create!(:fact => Factory(:fact,
                                   :day => DateTime.civil(2011, 11, 22, 12, 0, 0),
                                   :from => share2,
                                   :to => bank,
                                   :resource => rub,
                                   :amount => 100000.0))
    Txn.create!(:fact => Factory(:fact,
                                   :day => DateTime.civil(2011, 11, 22, 12, 0, 0),
                                   :from => share1,
                                   :to => bank,
                                   :resource => rub,
                                   :amount => 142000.0))
    Txn.create!(:fact => Factory(:fact,
                                      :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                      :from => bank,
                                      :to => purchase,
                                      :resource => rub,
                                      :amount => 70000.0))
    Txn.create!(:fact => Factory(:fact,
                :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                :from => forex1,
                :to => bank2,
                :resource => eur,
                :amount => 1000.0))
    Txn.create!(:fact => Factory(:fact,
                                   :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                   :from => bank,
                                   :to => forex1,
                                   :resource => rub,
                                   :amount => 34950.0))
    Txn.create!(:fact => Factory(:fact,
                 :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                 :from => bank2,
                 :to => forex2,
                 :resource => eur,
                 :amount => 1000.0))
    Txn.create!(:fact => Factory(:fact,
                                    :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                    :from => forex2,
                                    :to => bank,
                                    :resource => forex2.take,
                                    :amount => 1000.0 * forex2.rate))
    forex = Factory(:deal, :rate => (1 / 34.2), :give => bank.give, :take => bank2.take)
    Txn.create!(:fact => Factory(:fact,
                                    :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                    :amount => (5000.0 / forex.rate).accounting_norm,
                                    :from => bank,
                                    :to => forex,
                                    :resource => forex.give))
    Txn.create!(:fact => Factory(:fact,
                 :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                 :amount => 5000.0,
                 :from => forex,
                 :to => bank2,
                 :resource => forex.take))
    office = Factory(:deal, :rate => (1 / 2000.0), :give => bank.give, :take => Factory(:asset))
    Txn.create!(:fact => Factory(:fact,
                :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                :from => office,
                :to => Deal.income,
                :resource => office.take))
    forex = Factory(:deal, :rate => 34.95, :give => bank2.give, :take => bank.give)
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => 2000.0, :from => bank2, :to => forex,
                                   :resource => forex.give))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => (2500.0 * 34.95), :from => forex, :to => bank,
                                       :resource => forex.take))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => 600.0, :from => bank2, :to => forex,
                                   :resource => forex.give))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => (100.0 * 34.95), :from => forex, :to => bank,
                                   :resource => forex.take))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                 :amount => (2 * 2000.0), :from => bank, :to => office,
                                 :resource => office.give))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 25, 12, 0, 0),
                                   :amount => 50.0, :from => bank, :to => Deal.income,
                                   :resource => bank.take))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 26, 12, 0, 0),
                                   :amount => 50.0, :from => Deal.income, :to => bank,
                                   :resource => bank.give))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => (400.0 * 34.95), :from => forex, :to => bank,
                                   :resource => bank.give))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => 400.0, :from => bank2, :to => Deal.income,
                                   :resource => bank2.take))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 27, 12, 0, 0),
                                   :amount => 400.0, :from => Deal.income, :to => forex,
                                   :resource => forex.give))

    bs = Balance.find_all_by_time_frame DateTime.now, DateTime.now
    bs.count.should eq(6)
    (bs + Income.find_all_by_time_frame(DateTime.now, DateTime.now)).count.should eq(7)

    dt = DateTime.now
    dt.should eq(BalanceSheet.new(dt).date)

    bs = BalanceSheet.new
    bs.count.should eq(7)
    bs.last.value.should eq((400.0 * (34.95 - 34.2)).accounting_norm)
    bs.last.side.should eq(Income::PASSIVE)
    bs.assets.should eq(242300.0)
    bs.liabilities.should eq(242300.0)

    bs = BalanceSheet.new DateTime.civil(2011, 11, 26, 12, 0, 0)
    bs.count.should eq(6)
    bs.assets.should eq(242000.0)
    bs.liabilities.should eq(242000.0)
    bs.to_a.should =~ Balance.find_all_by_time_frame(DateTime.civil(2011, 11, 27, 12, 0, 0),
                                                     DateTime.civil(2011, 11, 26, 12, 0, 0))
  end
end
