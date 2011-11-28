# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require "spec_helper"

describe Float do
  it "should add accounting methods" do
    #describe "#accounting_zero?"
    0.0.accounting_zero?.should be_true
    0.00009.accounting_zero?.should be_false
    -0.00009.accounting_zero?.should be_false
    -0.000071.accounting_zero?.should be_true
    0.000081.accounting_zero?.should be_true
    0.03.accounting_zero?.should be_false
    #describe "#accounting_round64"
    100.05.accounting_round64.should eq(100.0)
    -100.05.accounting_round64.should eq(-100.0)
    100.8.accounting_round64.should eq(101.0)
    -100.8.accounting_round64.should eq(-101.0)
    #describe "#accounting_norm"
    1.0005.accounting_round64.should eq(1.0)
    -1.0005.accounting_round64.should eq(-1.0)
    100.8.accounting_round64.should eq(101)
    -100.8.accounting_round64.should eq(-101)
    #describe "#accounting_negative?"
    0.0.accounting_negative?.should be_false
    0.00009.accounting_negative?.should be_false
    -0.00009.accounting_negative?.should be_true
    -0.000071.accounting_negative?.should be_false
    0.000081.accounting_negative?.should be_false
    0.03.accounting_negative?.should be_false
    -0.03.accounting_negative?.should be_true
  end
end