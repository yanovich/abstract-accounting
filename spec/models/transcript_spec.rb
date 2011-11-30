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

    t_share2_to_bank = Txn.create!(:fact => Factory(:fact,
                                   :day => DateTime.civil(2011, 11, 22, 12, 0, 0),
                                   :from => share2,
                                   :to => bank,
                                   :resource => rub,
                                   :amount => 100000.0))
    t_share_to_bank = Txn.create!(:fact => Factory(:fact,
                                   :day => DateTime.civil(2011, 11, 22, 12, 0, 0),
                                   :from => share1,
                                   :to => bank,
                                   :resource => rub,
                                   :amount => 142000.0))
    t_bank_to_purchase = Txn.create!(:fact => Factory(:fact,
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
    t_bank_to_forex = Txn.create!(:fact => Factory(:fact,
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
    t_forex2_to_bank = Txn.create!(:fact => Factory(:fact,
                                    :day => DateTime.civil(2011, 11, 23, 12, 0, 0),
                                    :from => forex2,
                                    :to => bank,
                                    :resource => forex2.take,
                                    :amount => 1000.0 * forex2.rate))
    forex = Factory(:deal, :rate => (1 / 34.2), :give => bank.give, :take => bank2.take)
    t_bank_to_forex3 = Txn.create!(:fact => Factory(:fact,
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
    t_forex4_to_bank = Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                       :amount => (2500.0 * 34.95), :from => forex, :to => bank,
                                       :resource => forex.take))
    Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => 600.0, :from => bank2, :to => forex,
                                   :resource => forex.give))
    t2_forex4_to_bank = Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
                                   :amount => (100.0 * 34.95), :from => forex, :to => bank,
                                   :resource => forex.take))
    t_bank_to_office = Txn.create!(:fact => Factory(:fact, :day => DateTime.civil(2011, 11, 24, 12, 0, 0),
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

    txns = bank.txns(DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 22, 12, 0, 0))
    txns.count.should eq(2)
    txns.each { |txn| txn.should be_kind_of(Txn); [txn.fact.from, txn.fact.to].should include(bank) }
    txns = bank.txns(DateTime.civil(2011, 11, 23, 12, 0, 0), DateTime.civil(2011, 11, 23, 12, 0, 0))
    txns.count.should eq(4)
    txns.each { |txn| txn.should be_kind_of(Txn); [txn.fact.from, txn.fact.to].should include(bank) }

    balances = bank.balances_by_time_frame(DateTime.civil(2011, 11, 22, 12, 0, 0),
                                            DateTime.civil(2011, 11, 22, 12, 0, 0))
    balances.count.should eq(1)
    balances.first.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    balances.first.paid.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))

    tr = Transcript.new(bank, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.deal.should eq(bank)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(100000.0 + 142000.0)
    tr.closing.value.should eq(100000.0 + 142000.0)
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(2)
    tr.to_a.should =~ [t_share2_to_bank, t_share_to_bank]


    tr = Transcript.new(bank, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 23, 12, 0, 0))
    tr.deal.should eq(bank)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(100000.0 + 142000.0 - 70000.0 +
                                (1000.0 * (forex2.rate - (1 / forex1.rate))).accounting_norm - (5000.0 * 34.2))
    tr.closing.value.should eq(100000.0 + 142000.0 - 70000.0 +
                              (1000.0 * (forex2.rate - (1 / forex1.rate))).accounting_norm - (5000.0 * 34.2))
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(6)
    tr.to_a.should =~ [t_share2_to_bank, t_share_to_bank, t_bank_to_forex,
                       t_bank_to_forex3, t_bank_to_purchase, t_forex2_to_bank]

    tr.total_debits.should eq(100000.0 + 142000.0 + 1000.0 * forex2.rate)
    tr.total_debits_value.should eq(100000.0 + 142000.0 + 1000.0 * forex2.rate)

    tr.total_credits.should eq(70000.0 + 5000.0 * 34.2 + 34950.0)
    tr.total_credits_value.should eq(70000.0 + 5000.0 * 34.2 + 34950.0)


    tr = Transcript.new(bank, DateTime.civil(2011, 11, 23, 12, 0, 0), DateTime.civil(2011, 11, 24, 12, 0, 0))
    tr.deal.should eq(bank)
    tr.start.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 24, 12, 0, 0))

    tr.opening.amount.should eq(100000.0 + 142000.0)
    tr.opening.value.should eq(100000.0 + 142000.0)
    tr.opening.side.should eq(Balance::ACTIVE)
    tr.closing.amount.should eq(100000.0 + 142000.0 - 70000.0 +
                                (1000.0 * (forex2.rate - (1 / forex1.rate))).accounting_norm - (5000.0 * 34.2) +
                                (2500.0 * 34.95) + (100 * 34.95) - (2 * 2000.0))
    tr.closing.value.should eq(100000.0 + 142000.0 - 70000.0 +
                              (1000.0 * (forex2.rate - (1 / forex1.rate))).accounting_norm - (5000.0 * 34.2) +
                              (2500.0 * 34.95) + (100 * 34.95) - (2 * 2000.0))
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(7)
    tr.to_a.should =~ [t_bank_to_forex, t_bank_to_forex3, t_bank_to_purchase, t_forex2_to_bank,
                       t_forex4_to_bank, t2_forex4_to_bank, t_bank_to_office]


    tr = Transcript.new(bank, DateTime.civil(2011, 11, 21, 12, 0, 0), DateTime.civil(2011, 11, 21, 12, 0, 0))
    tr.deal.should eq(bank)
    tr.start.should eq(DateTime.civil(2011, 11, 21, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 21, 12, 0, 0))
    tr.opening.should be_nil
    tr.closing.should be_nil
    tr.should be_empty

    tr = Transcript.new(purchase, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 23, 12, 0, 0))
    tr.deal.should eq(purchase)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 23, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.amount.should eq(1.0)
    tr.closing.value.should eq(70000.0)
    tr.closing.side.should eq(Balance::ACTIVE)

    tr.count.should eq(1)
    tr.to_a.should =~ [t_bank_to_purchase]
    #pnl_transcript
    tr = Transcript.new(Deal.income, DateTime.civil(2011, 11, 22, 12, 0, 0), DateTime.civil(2011, 11, 27, 12, 0, 0))
    tr.deal.should eq(Deal.income)
    tr.start.should eq(DateTime.civil(2011, 11, 22, 12, 0, 0))
    tr.stop.should eq(DateTime.civil(2011, 11, 27, 12, 0, 0))

    tr.opening.should be_nil
    tr.closing.value.should eq((400.0 * (34.95 - 34.2)).accounting_norm)
    tr.closing.side.should eq(Income::PASSIVE)

    tr.count.should eq(8)
    tr.first.fact.amount.should eq(1000.0)
    tr.first.value.should eq(1000.0 * 34.95)
    tr.first.earnings.should eq((1000.0 * (35.0 - 34.95)).accounting_norm)
    tr.last.fact.amount.should eq(400.0)
    tr.last.value.should eq(0.0)
    tr.last.earnings.should eq((400.0 * 34.95).accounting_norm)
  end
end
