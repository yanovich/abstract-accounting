# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Fact do
  it "should validate attributes" do
    should validate_presence_of :day
    should validate_presence_of :amount
    should validate_presence_of :resource_id
    should validate_presence_of :to_deal_id
    should belong_to :resource
    should belong_to :from
    should belong_to :to
    should have_one :txn
    should have_many Fact.versions_association_name
    Factory.build(:fact).should be_valid
    Factory.build(:fact, :from => Factory(:deal)).should_not be_valid

    #check state calculation
    rub = Factory(:money)
    eur = Factory(:money)
    aasii = Factory(:asset)
    share2 = Factory(:deal, :give => aasii, :take => rub, :rate => 10000.0)
    share1 = Factory(:deal, :give => aasii, :take => rub, :rate => 10000.0)
    bank = Factory(:deal, :give => rub, :take => rub, :rate => 1.0)
    purchase = Factory(:deal, :give => rub, :rate => 0.0000142857143)
    bank2 = Factory(:deal, :give => eur, :take => eur, :rate => 1.0)
    forex = Factory(:deal, :give => rub, :take => eur, :rate => 0.028612303)
    forex2 = Factory(:deal, :give => eur, :take => rub, :rate => 35.0)

    fact = Factory(:fact, :from => share2, :to => bank, :resource => rub, :amount => 100000.0)
    share2.state(fact.day).resource.should eq(aasii)
    share2.state(fact.day).amount.should eq(10.0)
    bank.state(fact.day).resource.should eq(rub)
    bank.state(fact.day).amount.should eq(100000.0)

    fact = Factory(:fact, :from => share1, :to => bank, :resource => rub, :amount => 142000.0)
    share2.state(fact.day).resource.should eq(aasii)
    share2.state(fact.day).amount.should eq(10.0)
    share1.state(fact.day).resource.should eq(aasii)
    share1.state(fact.day).amount.should eq(14.2)
    bank.state(fact.day).resource.should eq(rub)
    bank.state(fact.day).amount.should eq(242000.0)

    fact = Factory(:fact, :from => bank, :to => purchase, :resource => rub, :amount => 70000.0)
    share2.state(fact.day).resource.should eq(aasii)
    share2.state(fact.day).amount.should eq(10.0)
    share1.state(fact.day).resource.should eq(aasii)
    share1.state(fact.day).amount.should eq(14.2)
    bank.state(fact.day).resource.should eq(rub)
    bank.state(fact.day).amount.should eq(172000.0)
    purchase.state(fact.day).resource.should eq(purchase.take)
    purchase.state(fact.day).amount.should eq(1.0)
    purchase.states.each do |state|
      state.paid.should eq(fact.day) if state != purchase.state(fact.day)
    end

    fact = Factory(:fact, :from => forex, :to => bank2, :resource => eur, :amount => 1000.0)
    share2.state(fact.day).resource.should eq(aasii)
    share2.state(fact.day).amount.should eq(10.0)
    share1.state(fact.day).resource.should eq(aasii)
    share1.state(fact.day).amount.should eq(14.2)
    bank.state(fact.day).resource.should eq(rub)
    bank.state(fact.day).amount.should eq(172000.0)
    purchase.state(fact.day).resource.should eq(purchase.take)
    purchase.state(fact.day).amount.should eq(1.0)
    bank2.state(fact.day).resource.should eq(eur)
    bank2.state(fact.day).amount.should eq(1000.0)
    forex.state(fact.day).resource.should eq(rub)
    forex.state(fact.day).amount.should eq(34950.0)

    fact = Factory(:fact, :from => bank, :to => forex, :resource => rub, :amount => 34950.0)
    share2.state(fact.day).resource.should eq(aasii)
    share2.state(fact.day).amount.should eq(10.0)
    share1.state(fact.day).resource.should eq(aasii)
    share1.state(fact.day).amount.should eq(14.2)
    bank.state(fact.day).resource.should eq(rub)
    bank.state(fact.day).amount.should eq(137050.0)
    purchase.state(fact.day).resource.should eq(purchase.take)
    purchase.state(fact.day).amount.should eq(1.0)
    bank2.state(fact.day).resource.should eq(eur)
    bank2.state(fact.day).amount.should eq(1000.0)
    forex.state.should be_nil

    fact = Factory(:fact, :from => bank2, :to => forex2, :resource => eur, :amount => 1000.0)
    share2.state(fact.day).resource.should eq(aasii)
    share2.state(fact.day).amount.should eq(10.0)
    share1.state(fact.day).resource.should eq(aasii)
    share1.state(fact.day).amount.should eq(14.2)
    bank.state(fact.day).resource.should eq(rub)
    bank.state(fact.day).amount.should eq(137050.0)
    purchase.state(fact.day).resource.should eq(purchase.take)
    purchase.state(fact.day).amount.should eq(1.0)
    bank2.state.should be_nil
    forex.state.should be_nil
    forex2.state(fact.day).resource.should eq(rub)
    forex2.state(fact.day).amount.should eq(35000.0)
  end
end
