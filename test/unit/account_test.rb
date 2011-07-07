# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details
require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  test "float accounting zero" do
    assert 0.0.accounting_zero?, "0.0 is not zero"
    assert !0.00009.accounting_zero?, "0.00009 is zero"
    assert !-0.00009.accounting_zero?, "-0.00009 is zero"
    assert -0.000071.accounting_zero?, "-0.000071 is not zero"
    assert 0.000081.accounting_zero?, "0.000081 is not zero"
    assert !0.03.accounting_zero?, "0.03 is zero"
  end

  test "float accounting round64" do
    assert_equal 100.0, 100.05.accounting_round64,
      "100.05 accounting round fail"
    assert_equal -100.0, -100.05.accounting_round64,
      "-100.05 accounting round fail"
    assert_equal 101.0, 100.8.accounting_round64,
      "100.8 accounting round fail"
    assert_equal -101.0, -100.8.accounting_round64,
      "-100.8 accounting round fail"
  end

  test "float accounting norm" do
    assert_equal 1.0, 1.0005.accounting_norm,
      "1.0005 accounting round fail"
    assert_equal -1.0, -1.0005.accounting_norm,
      "-1.0005 accounting round fail"
    assert_equal 1.01, 1.008.accounting_norm,
      "1.008 accounting round fail"
    assert_equal -1.01, -1.008.accounting_norm,
      "-1.008 accounting round fail"
  end

  test "float accounting negative" do
    assert !0.0.accounting_negative?, "0.0 is negative"
    assert !0.00009.accounting_negative?, "0.00009 is negative"
    assert -0.00009.accounting_negative?, "-0.00009 is not negative"
    assert !-0.000071.accounting_negative?, "-0.000071 is negative"
    assert !0.000081.accounting_negative?, "0.000081 is negative"
    assert !0.03.accounting_negative?, "0.03 is negative"
    assert -0.03.accounting_negative?, "-0.03 is not negative"
  end


  test "balance should save" do
    assert_equal 0, Balance.all.count, "Balance count is not 0"
    b = Balance.new
    assert_equal "active", b.side, "Balance is not initialized"
    assert b.invalid?, "Empty Balance is valid"
    b.deal = Deal.first
    assert b.invalid?, "Balance with deal is valid"
    b.start = DateTime.civil(2011, 1, 8)
    b.amount = 5000
    b.side = "passive"
    b.value = 54.0
    assert b.valid?, "Balance is invalid"
    b.side = "passive2"
    assert b.invalid?, "Balance with wrong side is valid"
    b.side = "active"
    assert b.save, "Balance is not saved"
    assert Balance.new(:deal => Deal.first, :amount => 51, :value => 43,
      :side => "passive", :start => DateTime.civil(2011, 1, 8)).invalid?,
      "Balance with not unique deal and start is valid"
    b.destroy
    assert_equal 0, Balance.all.count, "Balance is not deleted"
  end
end
