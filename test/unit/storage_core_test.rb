# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class StorageCore < ActiveSupport::TestCase
  test "share 2 to bank" do
    s2tb = Fact.new(:amount => 100000.0,
      :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
      :from => deals(:equityshare2),
      :to => deals(:bankaccount),
      :resource => deals(:equityshare2).take)
    assert s2tb.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), s2tb.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:bankaccount), s2tb.day, 100000.0,
        deals(:bankaccount).take)

    stb = Fact.new(:amount => 142000.0,
      :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
      :from => deals(:equityshare1),
      :to => deals(:bankaccount),
      :resource => deals(:equityshare1).take)
    assert stb.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), stb.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:equityshare1), stb.day, 14.2,
        deals(:equityshare1).give)
    assert_equal true,
      check_state(deals(:bankaccount), stb.day, 242000.0,
        deals(:bankaccount).take)

    batp = Fact.new(:amount => 70000.0,
      :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
      :from => deals(:bankaccount),
      :to => deals(:purchase),
      :resource => deals(:bankaccount).take)
    assert batp.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), batp.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:equityshare1), batp.day, 14.2,
        deals(:equityshare1).give)
    assert_equal true,
      check_state(deals(:bankaccount), batp.day, 172000.0,
        deals(:bankaccount).take)
    assert_equal true,
      check_state(deals(:purchase), batp.day, 1.0, deals(:purchase).take)

    assert_equal batp.day, deals(:bankaccount).state(stb.day).paid,
      "Wrong state paid"
    assert_equal true,
      check_state(deals(:bankaccount), stb.day, 242000.0,
        deals(:bankaccount).take)

    ftba2 = Fact.new(:amount => 1000.0,
      :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
      :from => deals(:forex),
      :to => deals(:bankaccount2),
      :resource => deals(:forex).take)
    assert ftba2.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), ftba2.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:equityshare1), ftba2.day, 14.2,
        deals(:equityshare1).give)
    assert_equal true,
      check_state(deals(:bankaccount), ftba2.day, 172000.0,
        deals(:bankaccount).take)
    assert_equal true,
      check_state(deals(:purchase), ftba2.day, 1.0, deals(:purchase).take)
    assert_equal true,
      check_state(deals(:forex), ftba2.day, 34950.0, deals(:forex).give)
    assert_equal true,
      check_state(deals(:bankaccount2), ftba2.day, 1000.0,
        deals(:bankaccount2).take)

    batf = Fact.new(:amount => 34950.0,
      :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
      :from => deals(:bankaccount),
      :to => deals(:forex),
      :resource => deals(:bankaccount).take)
    assert batf.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), batf.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:equityshare1), batf.day, 14.2,
        deals(:equityshare1).give)
    assert_equal true,
      check_state(deals(:bankaccount), batf.day, 137050.0,
        deals(:bankaccount).take)
    assert_equal true,
      check_state(deals(:purchase), batf.day, 1.0, deals(:purchase).take)
    assert deals(:forex).state.nil?, "Forex deal have state"
    assert_equal true,
      check_state(deals(:bankaccount2), batf.day, 1000.0,
        deals(:bankaccount2).take)

    ba2tf2 = Fact.new(:amount => 1000.0,
      :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
      :from => deals(:bankaccount2),
      :to => deals(:forex2),
      :resource => deals(:bankaccount2).take)
    assert ba2tf2.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), ba2tf2.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:equityshare1), ba2tf2.day, 14.2,
        deals(:equityshare1).give)
    assert_equal true,
      check_state(deals(:bankaccount), ba2tf2.day, 137050.0,
        deals(:bankaccount).take)
    assert_equal true,
      check_state(deals(:purchase), ba2tf2.day, 1.0, deals(:purchase).take)
    assert deals(:forex).state.nil?, "Forex deal have state"
    assert deals(:bankaccount2).state.nil?,
      "Bank account 2 deal have state"
    assert_equal true,
      check_state(deals(:forex2), ba2tf2.day, 35000.0,
        deals(:forex2).take)
    ba2tba = Fact.new(:amount => 1.0,
      :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
      :from => deals(:bankaccount2),
      :to => deals(:bankaccount),
      :resource => deals(:bankaccount2).take)
    assert !ba2tba.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), ba2tba.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:equityshare1), ba2tba.day, 14.2,
        deals(:equityshare1).give)
    assert_equal true,
      check_state(deals(:bankaccount), ba2tba.day, 137050.0,
        deals(:bankaccount).take)
    assert_equal true,
      check_state(deals(:purchase), ba2tba.day, 1.0, deals(:purchase).take)
    assert deals(:forex).state.nil?, "Forex deal have state"
    assert deals(:bankaccount2).state.nil?,
      "Bank account 2 deal have state"
    assert_equal true,
      check_state(deals(:forex2), ba2tba.day, 35000.0,
        deals(:forex2).take)
  end

  private
  def check_state(deal, day, amount, resource)
    deal_state = deal.state(day)
    if deal_state.nil?
      "#{deal.tag} state not found"
    elsif amount != deal_state.amount
      "#{deal.tag} state amount(#{deal_state.amount}) is not equal to #{amount}"
    elsif resource != deal_state.resource
      "#{deal.tag} invalid state resource"
    else
      true
    end
  end
end
