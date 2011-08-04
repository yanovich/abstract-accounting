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

  test "account test" do
    init_facts
    assert !Fact.pendings.nil?, "Pending facts is nil"
    assert_equal 6, Fact.pendings.count, "Pending facts count is not equal to 6"
    pending_fact = Fact.pendings.first
    assert_equal 100000.0, pending_fact.amount, "Wrong pending fact amount"
    assert_equal deals(:equityshare2), pending_fact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:bankaccount), pending_fact.to,
      "Wrong pending fact to deal"
    assert_equal 1, Chart.all.count, "Wrong chart count"
    assert_equal money(:rub), Chart.all.first.currency,
      "Wrong chart currency"

    t = Txn.new :fact => pending_fact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"
    bfrom = t.from_balance
    assert !bfrom.nil?, "Balance is nil"
    assert_equal pending_fact.from, bfrom.deal, "From balance invalid deal"
    assert_equal pending_fact.from.give, bfrom.resource,
      "From balance invalid resource"
    assert_equal Balance::PASSIVE, bfrom.side, "From balance invalid side"
    assert_equal pending_fact.amount / deals(:equityshare2).rate, bfrom.amount,
      "From balance amount is not equal"
    assert_equal pending_fact.amount, bfrom.value,
      "From balance value is not equal"
    assert_equal pending_fact.amount, t.value,
        "Wrong txn value"
    bto = t.to_balance
    assert !bto.nil?, "Balance is nil"
    assert_equal pending_fact.to, bto.deal, "To balance invalid deal"
    assert_equal pending_fact.to.take, bto.resource,
      "To balance invalid resource"
    assert_equal Balance::ACTIVE, bto.side, "To balance invalid side"
    assert_equal pending_fact.amount, bto.amount,
      "To balance amount is not equal"
    assert_equal pending_fact.amount, bto.value,
      "To balance value is not equal"

    assert_equal 5, Fact.pendings.count, "Pending facts count is not equal to 5"
    pending_fact = Fact.pendings.first
    assert_equal 142000.0, pending_fact.amount, "Wrong pending fact amount"
    assert_equal deals(:equityshare1), pending_fact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:bankaccount), pending_fact.to,
      "Wrong pending fact to deal"
    t = Txn.new :fact => pending_fact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"
    assert_equal 3, Balance.open.count, "Balance count is not equal to 3"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    assert_equal pending_fact.amount, t.value,
        "Wrong txn value"

    assert_equal 4, Fact.pendings.count, "Pending facts count is not equal to 4"
    pending_fact = Fact.pendings.first
    assert_equal 70000.0, pending_fact.amount, "Wrong pending fact amount"
    assert_equal deals(:bankaccount), pending_fact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:purchase), pending_fact.to,
      "Wrong pending fact to deal"
    t = Txn.new :fact => pending_fact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"
    assert_equal 4, Balance.open.count, "Balance count is not equal to 4"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:purchase), b.deal, "balance invalid deal"
    assert_equal deals(:purchase).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 1.0, b.amount,
      "balance amount is not equal"
    assert_equal 70000.0, b.value,
      "balance value is not equal"
    assert_equal 70000.0, t.value
    b = Balance.where("balances.paid IS NOT NULL").
                where(:deal_id => deals(:bankaccount).id).first
    assert !b.nil?, "Wrong closed balance"
    assert_equal DateTime.civil(2007, 8, 30, 12, 0, 0), b.paid,
      "Wrong balance paid"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0, b.value,
      "balance value is not equal"

    t = Txn.new :fact => Fact.pendings.first
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"
    assert_equal 6, Balance.open.count, "Balance count is not equal to 7"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0 - 70000.0, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:purchase), b.deal, "balance invalid deal"
    assert_equal deals(:purchase).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 1.0, b.amount,
      "balance amount is not equal"
    assert_equal 70000.0, b.value,
      "balance value is not equal"
    b = deals(:forex).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:forex), b.deal, "balance invalid deal"
    assert_equal deals(:forex).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.amount,
      "balance amount is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount2), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount2).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 1000.0, b.amount,
      "balance amount is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, t.value,
      "wrong txn value"

    assert_equal 2, Fact.pendings.count, "Pending facts count is not equal to 2"
    pending_fact = Fact.pendings.first
    assert_equal 34950.0, pending_fact.amount, "Wrong pending fact amount"
    assert_equal deals(:bankaccount), pending_fact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:forex), pending_fact.to,
      "Wrong pending fact to deal"
    t = Txn.new :fact => pending_fact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"
    assert_equal 5, Balance.open.count, "Balance count is not equal to 6"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0 - 70000.0 -
      (1000.0 / deals(:forex).rate).accounting_norm, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0 - 70000.0 -
      (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:purchase), b.deal, "balance invalid deal"
    assert_equal deals(:purchase).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 1.0, b.amount,
      "balance amount is not equal"
    assert_equal 70000.0, b.value,
      "balance value is not equal"
    b = deals(:forex).balance
    assert b.nil?, "Balance is not nil"
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount2), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount2).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 1000.0, b.amount,
      "balance amount is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"
    assert_equal (1000.0 / deals(:forex).rate).accounting_norm,
      Fact.find(pending_fact.id).txn.value, "Txn value is not equal"

    assert_equal 1, Fact.pendings.count, "Pending facts count is not equal to 2"
    pending_fact = Fact.pendings.first
    assert_equal 1000.0, pending_fact.amount, "Wrong pending fact amount"
    assert_equal deals(:bankaccount2), pending_fact.from,
      "Wrong pending fact from deal"
    assert_equal deals(:forex2), pending_fact.to,
      "Wrong pending fact to deal"
    t = Txn.new :fact => pending_fact
    assert t.valid?, "Transaction is not valid"
    assert t.save, "Txn is not saved"
    assert_equal (1000.0/deals(:forex).rate).accounting_norm,
      Fact.find(pending_fact.id).txn.value, "Txn value is not equal"
    assert_equal 1, Fact.find(pending_fact.id).txn.status,
      "Txn status is not equal"
    assert_equal (1000.0 * (deals(:forex2).rate -
        (1/deals(:forex).rate))).accounting_norm,
      Fact.find(pending_fact.id).txn.earnings, "Txn earning is not equal"
    assert_equal 5, Balance.open.count, "Balance count is not equal to 5"
    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare2), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare2).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 100000.0 / deals(:equityshare2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0, b.value,
      "balance value is not equal"
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:bankaccount), b.deal, "balance invalid deal"
    assert_equal deals(:bankaccount).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 100000.0 + 142000.0 - 70000.0 -
      (1000.0 / deals(:forex).rate).accounting_norm, b.amount,
      "balance amount is not equal"
    assert_equal 100000.0 + 142000.0 - 70000.0 -
      (1000.0 / deals(:forex).rate).accounting_norm, b.value,
      "balance value is not equal"
    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:equityshare1), b.deal, "balance invalid deal"
    assert_equal deals(:equityshare1).give, b.resource,
      "balance invalid resource"
    assert_equal Balance::PASSIVE, b.side, "balance invalid side"
    assert_equal 142000.0 / deals(:equityshare1).rate, b.amount,
      "balance amount is not equal"
    assert_equal 142000.0, b.value,
      "balance value is not equal"
    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:purchase), b.deal, "balance invalid deal"
    assert_equal deals(:purchase).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 1.0, b.amount,
      "balance amount is not equal"
    assert_equal 70000.0, b.value,
      "balance value is not equal"
    b = deals(:forex).balance
    assert b.nil?, "Balance is not nil"
    b = deals(:bankaccount2).balance
    assert b.nil?, "Balance is not nil"
    b = deals(:forex2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal deals(:forex2), b.deal, "balance invalid deal"
    assert_equal deals(:forex2).take, b.resource,
      "balance invalid resource"
    assert_equal Balance::ACTIVE, b.side, "balance invalid side"
    assert_equal 1000.0 * deals(:forex2).rate, b.amount,
      "balance amount is not equal"
    assert_equal 1000.0 * deals(:forex2).rate, b.value,
      "balance value is not equal"

    assert_equal 1, Income.open.count, "Income count is wrong"
    profit = (1000.0 * (deals(:forex2).rate -
      (1/deals(:forex).rate))).accounting_norm
    assert_equal profit, Income.open.first.value, "Invalid income value"
    assert_equal 0, Fact.pendings.count, "Pending facts count is wrong"
  end

  test "loss transaction" do
    init_facts.each do |fact|
      assert Txn.new(:fact => fact).save, "Txn is not saved"
    end

    f = Fact.new(:amount => 1000.0 * deals(:forex2).rate,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:forex2),
                :to => deals(:bankaccount),
                :resource => deals(:forex2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert !Balance.open.nil?, "Open balances is nil"
    assert_equal 4, Balance.open.count, "Open balances count is wrong"

    b = deals(:equityshare2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal (100000.0 / deals(:equityshare2).rate).accounting_norm,
      b.amount, "Wrong balance amount"
    assert_equal 100000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"

    b = deals(:equityshare1).balance
    assert !b.nil?, "Balance is nil"
    assert_equal (142000.0 / deals(:equityshare1).rate).accounting_norm,
      b.amount, "Wrong balance amount"
    assert_equal 142000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"

    b = deals(:purchase).balance
    assert !b.nil?, "Balance is nil"
    assert_equal (70000.0 * deals(:purchase).rate).accounting_norm,
      b.amount, "Wrong balance amount"
    assert_equal 70000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    b = deals(:bankaccount).balance
    value = 100000.0 + 142000.0 - 70000.0 +
      (1000.0 * (deals(:forex2).rate - 1 / deals(:forex).rate))
    assert !b.nil?, "Balance is nil"
    assert_equal value.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal value.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    forex = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert forex.save, "Forex deal 3 is not saved"

    f = Fact.new(:amount => (5000.0 / forex.rate).accounting_norm,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => forex,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 5, Balance.open.count, "Open balances count is wrong"
    b = deals(:bankaccount).balance
    value -= (5000.0 / forex.rate).accounting_norm
    assert !b.nil?, "Balance is nil"
    assert_equal value.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal value.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = forex.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal (5000.0 / forex.rate).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    f = Fact.new(:amount => 5000.0,
                :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount2),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 5, Balance.open.count, "Open balances count is wrong"
    assert forex.balance.nil?, "Balance is not nil"
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal (5000.0 / forex.rate).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    landlord = Entity.new :tag => "Audit service"
    assert landlord.save, "Audit service not saved"
    rent = Asset.new :tag => "office space"
    assert rent.save, "Asset not saved"
    office = Deal.new :tag => "rented office 1",
      :rate => (1 / 2000.0),
      :entity => landlord,
      :give => money(:rub),
      :take => rent
    assert office.save, "Flow is not saved"

    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                :from => office,
                :to => Deal.income,
                :resource => office.take)
    assert f.valid?, "Fact is not valid"
    assert f.save, "Fact is not saved"

    assert_equal 6, State.open.count, "State count is wrong"
    s = office.state
    assert !s.nil?, "State is nil"
    assert_equal (1 / office.rate).accounting_norm, s.amount,
      "State amount is wrong"
    assert_equal money(:rub), s.resource, "State resource is wrong"

    s = deals(:bankaccount).state
    assert !s.nil?, "State is nil"
    assert_equal value.accounting_norm, s.amount,
      "State amount is wrong"
    assert_equal money(:rub), s.resource, "State resource is wrong"

    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Balance count is wrong"
    assert t.to_balance.nil?, "To balance is not nil"
    assert !t.from_balance.nil?, "From balance is nil"
    assert_equal (1 / office.rate).accounting_norm, t.from_balance.amount,
      "From balance amount is wrong"
    assert_equal (1 / office.rate).accounting_norm, t.from_balance.value,
      "From balance value is wrong"
    assert_equal Balance::PASSIVE, t.from_balance.side, "From balance side is wrong"

    assert_equal 1, Income.open.count, "Income count is wrong"
    profit = (1000.0 * (deals(:forex2).rate -
          (1/deals(:forex).rate))).accounting_norm
    profit -= (1 / office.rate).accounting_norm
    assert_equal profit, Income.first.value, "Income value is wrong"
  end

  test "split transaction" do
    init_facts.each do |fact|
      assert Txn.new(:fact => fact).save, "Txn is not saved"
    end

    f = Fact.new(:amount => 1000.0 * deals(:forex2).rate,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:forex2),
                :to => deals(:bankaccount),
                :resource => deals(:forex2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    forex = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert forex.save, "Forex deal 3 is not saved"

    f = Fact.new(:amount => (5000.0 / forex.rate).accounting_norm,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => forex,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    f = Fact.new(:amount => 5000.0,
                :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount2),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    landlord = Entity.new :tag => "Audit service"
    assert landlord.save, "Audit service not saved"
    rent = Asset.new :tag => "office space"
    assert rent.save, "Asset not saved"
    office = Deal.new :tag => "rented office 1",
      :rate => (1 / 2000.0),
      :entity => landlord,
      :give => money(:rub),
      :take => rent
    assert office.save, "Flow is not saved"

    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                :from => office,
                :to => Deal.income,
                :resource => office.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    profit = (1000.0 * (deals(:forex2).rate -
          (1/deals(:forex).rate))).accounting_norm
    profit -= (1 / office.rate).accounting_norm

    forex = Deal.new :tag => "forex deal 4",
      :rate => 34.95,
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub)
    assert forex.save, "Flow is not saved"

    f = Fact.new(:amount => 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Open balances count is wrong"
    euros = 5000.0 - t.fact.amount
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal euros, b.amount, "Wrong balance amount"
    assert_equal (euros * 34.2).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    b = forex.balance
    assert !b.nil?, "Balance is nil"
    assert_equal (t.fact.amount * forex.rate).accounting_norm, b.amount,
      "Wrong balance amount"
    assert_equal (t.fact.amount * forex.rate).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    assert_equal 1, Income.open.count, "Wrong open income count"
    assert_equal 2, Income.all.count, "Wrong income count"

    income = Income.where("incomes.paid IS NOT NULL").first
    assert !income.nil?, "Income is not found"
    assert_equal profit, income.value.accounting_norm, "Wrong income value"
    assert_equal Income::PASSIVE, income.side, "Wrong income side"
    assert_equal f.day, income.paid, "Wrong income paid value"
    assert_equal DateTime.civil(2007, 8, 31, 12, 0, 0), income.start, "Wrong income start value"
    profit += (34.95 - 34.2) * t.fact.amount
    assert_equal profit, Income.open.first.value.accounting_norm,
      "Wrong income value"

    f = Fact.new(:amount => (2500.0 * 34.95),
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert_equal 7, State.open.count, "Wrong open states count"

    s = forex.state
    assert !s.nil?, "Forex state is nil"
    assert_equal 2500.0 - 2000.0, s.amount, "Wrong forex state amount"
    assert_equal money(:eur), s.resource, "Wrong forex state resource"

    assert t.save, "Txn is not saved"
    assert_equal 87375.0, t.value, "Wrong txn value"
    assert_equal 1, Income.open.count, "Wrong open income count"

    assert_equal 7, Balance.open.count, "Wrong open balances count"
    b = forex.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 2500.0 - 2000.0, b.amount,
      "Wrong balance amount"
    assert_equal ((2500.0 - 2000.0) * 34.95).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"

    rubs = 100000.0 + 142000.0 - 70000.0 +
      (1000.0 * (deals(:forex2).rate - 1 / deals(:forex).rate))
    rubs -= (5000.0 * 34.2).accounting_norm
    rubs += t.fact.amount
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal rubs.accounting_norm, b.amount,
      "Wrong balance amount"
    assert_equal rubs.accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    assert_equal 1, Income.open.count, "Wrong open incomes count"
    assert_equal profit, Income.open.first.value, "Wrong income value"

    f = Fact.new(:amount => 600.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f

    assert_equal 7, State.open.count, "Wrong open states count"
    s = forex.state
    assert !s.nil?, "Forex state is nil"
    assert_equal (100.0 * 34.95).accounting_norm, s.amount, "Wrong forex state amount"
    assert_equal money(:rub), s.resource, "Wrong forex state resource"

    assert t.save, "Txn is not saved"
    assert_equal 450.0, t.earnings, "Wrong txn earnings"

    assert_equal 7, Balance.open.count, "Wrong open balances count"
    b = forex.balance
    assert !b.nil?, "Balance is nil"
    assert_equal (100.0 * 34.95).accounting_norm, b.amount,
      "Wrong balance amount"
    assert_equal (100.0 * 34.95).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    euros -= 600.0
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal (euros).accounting_norm, b.amount,
      "Wrong balance amount"
    assert_equal (euros * 34.2).accounting_norm, b.value,
      "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    assert_equal 0, Income.open.count, "Wrong open income count"
  end

  test "gain transaction" do
    init_facts.each do |fact|
      assert Txn.new(:fact => fact).save, "Txn is not saved"
    end

    f = Fact.new(:amount => 1000.0 * deals(:forex2).rate,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:forex2),
                :to => deals(:bankaccount),
                :resource => deals(:forex2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    forex = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert forex.save, "Forex deal 3 is not saved"

    f = Fact.new(:amount => (5000.0 / forex.rate).accounting_norm,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => forex,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    f = Fact.new(:amount => 5000.0,
                :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount2),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    landlord = Entity.new :tag => "Audit service"
    assert landlord.save, "Audit service not saved"
    rent = Asset.new :tag => "office space"
    assert rent.save, "Asset not saved"
    office = Deal.new :tag => "rented office 1",
      :rate => (1 / 2000.0),
      :entity => landlord,
      :give => money(:rub),
      :take => rent
    assert office.save, "Flow is not saved"

    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                :from => office,
                :to => Deal.income,
                :resource => office.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    profit = (1000.0 * (deals(:forex2).rate -
          (1/deals(:forex).rate))).accounting_norm
    profit -= (1 / office.rate).accounting_norm

    forex = Deal.new :tag => "forex deal 4",
      :rate => 34.95,
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub)
    assert forex.save, "Flow is not saved"

    f = Fact.new(:amount => 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    profit += (34.95 - 34.2) * t.fact.amount

    f = Fact.new(:amount => (2500.0 * 34.95),
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    rubs = 100000.0 + 142000.0 - 70000.0 +
      (1000.0 * (deals(:forex2).rate - 1 / deals(:forex).rate))
    rubs -= (5000.0 * 34.2).accounting_norm
    rubs += t.fact.amount

    f = Fact.new(:amount => 600.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    f = Fact.new(:amount => 100.0 * 34.95,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    assert forex.balances.empty?, "Forex 4 balance is not nil"

    rubs += 100.0 * 34.95
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal rubs.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal rubs.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    f = Fact.new(:amount => 2 * 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => office,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert_equal 6, State.open.count, "Open states count is wrong"
    s = office.state
    assert !s.nil?, "Office state is nil"
    assert_equal 1.0, s.amount, "Wrong forex state amount"
    assert_equal office.take, s.resource, "Wrong forex state resource"

    assert t.save, "Txn is not saved"
    assert_equal 6, Balance.open.count, "Wrong open balances count"
    rubs -= 2 * 2000.0
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal rubs.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal rubs.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = office.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 1.0, b.amount, "Wrong balance amount"
    assert_equal 2000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    assert_equal 0, Income.open.count, "Wrong open incomes count"

    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 6, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => Deal.income,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    rubs -= 50.0
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal rubs.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal rubs.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    assert_equal 1, Income.open.count, "Wrong open incomes count"
    profit += (34.95 - 34.2) * 600.0
    profit -= 50.0
    assert_equal profit, Income.open.first.value, "Wrong income value"

    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 7, 12, 0, 0),
                :from => Deal.income,
                :to => deals(:bankaccount),
                :resource => deals(:bankaccount).give)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    rubs += 50.0
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal rubs.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal rubs.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    assert_equal 0, Income.open.count, "Wrong open incomes count"
  end

  test "direct_gains_losses" do
    init_facts.each do |fact|
      assert Txn.new(:fact => fact).save, "Txn is not saved"
    end

    f = Fact.new(:amount => 1000.0 * deals(:forex2).rate,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:forex2),
                :to => deals(:bankaccount),
                :resource => deals(:forex2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    forex = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert forex.save, "Forex deal 3 is not saved"

    f = Fact.new(:amount => (5000.0 / forex.rate).accounting_norm,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => forex,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    f = Fact.new(:amount => 5000.0,
                :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount2),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    landlord = Entity.new :tag => "Audit service"
    assert landlord.save, "Audit service not saved"
    rent = Asset.new :tag => "office space"
    assert rent.save, "Asset not saved"
    office = Deal.new :tag => "rented office 1",
      :rate => (1 / 2000.0),
      :entity => landlord,
      :give => money(:rub),
      :take => rent
    assert office.save, "Flow is not saved"

    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                :from => office,
                :to => Deal.income,
                :resource => office.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    profit = (1000.0 * (deals(:forex2).rate -
          (1/deals(:forex).rate))).accounting_norm
    profit -= (1 / office.rate).accounting_norm

    forex = Deal.new :tag => "forex deal 4",
      :rate => 34.95,
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub)
    assert forex.save, "Flow is not saved"

    f = Fact.new(:amount => 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    euros = 5000.0 - t.fact.amount
    profit += (34.95 - 34.2) * t.fact.amount

    f = Fact.new(:amount => (2500.0 * 34.95),
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    rubs = 100000.0 + 142000.0 - 70000.0 +
      (1000.0 * (deals(:forex2).rate - 1 / deals(:forex).rate))
    rubs -= (5000.0 * 34.2).accounting_norm
    rubs += t.fact.amount

    f = Fact.new(:amount => 600.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    euros -= 600.0

    f = Fact.new(:amount => 100.0 * 34.95,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    rubs += 100.0 * 34.95

    f = Fact.new(:amount => 2 * 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => office,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    rubs -= 2 * 2000.0

    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 6, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => Deal.income,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    rubs -= 50.0
    profit += (34.95 - 34.2) * 600.0
    profit -= 50.0

    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 7, 12, 0, 0),
                :from => Deal.income,
                :to => deals(:bankaccount),
                :resource => deals(:bankaccount).give)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    rubs += 50.0
    profit += 50.0

    f = Fact.new(:amount => 400.0 * 34.95,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Wrong open balances count"
    b = forex.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 400.0, b.amount, "Wrong balance amount"
    assert_equal (400.0 * 34.95).accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"

    rubs += 400.0 * 34.95
    b = deals(:bankaccount).balance
    assert !b.nil?, "Balance is nil"
    assert_equal rubs.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal rubs.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    f = Fact.new(:amount => 400.0,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => Deal.income,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 7, Balance.open.count, "Wrong open balances count"


    euros -= 400.0
    b = deals(:bankaccount2).balance
    assert !b.nil?, "Balance is nil"
    assert_equal euros.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal (euros * 34.2).accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    assert_equal 1, Income.open.count, "Wrong open incomes count"
    profit -= 400.0 * 34.2
    assert_equal profit.accounting_norm, Income.open.first.value, "Wrong income value"

    f = Fact.new(:amount => 400.0,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => Deal.income,
                :to => forex,
                :resource => forex.give)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    assert_equal 6, Balance.open.count, "Wrong open balances count"
    b = Balance.open[0]
    assert !b.nil?, "Balance is nil"
    assert_equal 100000.0 / 10000.0, b.amount, "Wrong balance amount"
    assert_equal 100000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = Balance.open[1]
    assert !b.nil?, "Balance is nil"
    assert_equal 142000.0 / 10000.0, b.amount, "Wrong balance amount"
    assert_equal 142000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = Balance.open[2]
    assert !b.nil?, "Balance is nil"
    assert_equal 1.0, b.amount, "Wrong balance amount"
    assert_equal 70000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = Balance.open[3]
    assert !b.nil?, "Balance is nil"
    assert_equal 1.0, b.amount, "Wrong balance amount"
    assert_equal 2000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = Balance.open[4]
    assert !b.nil?, "Balance is nil"
    assert_equal rubs.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal rubs.accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = Balance.open[5]
    assert !b.nil?, "Balance is nil"
    assert_equal euros.accounting_norm, b.amount, "Wrong balance amount"
    assert_equal (euros * 34.2).accounting_norm, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
  end

  test "transcript" do
    init_facts.each do |fact|
      assert Txn.new(:fact => fact).save, "Txn is not saved"
    end
    f = Fact.new(:amount => 1000.0 * deals(:forex2).rate,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:forex2),
                :to => deals(:bankaccount),
                :resource => deals(:forex2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    forex = Deal.new :tag => "forex deal 3",
      :rate => (1 / 34.2),
      :entity => entities(:sbrfbank),
      :give => money(:rub),
      :take => money(:eur)
    assert forex.save, "Forex deal 3 is not saved"
    f = Fact.new(:amount => (5000.0 / forex.rate).accounting_norm,
                :day => DateTime.civil(2007, 9, 3, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => forex,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 5000.0,
                :day => DateTime.civil(2007, 9, 4, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount2),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    landlord = Entity.new :tag => "Audit service"
    assert landlord.save, "Audit service not saved"
    rent = Asset.new :tag => "office space"
    assert rent.save, "Asset not saved"
    office = Deal.new :tag => "rented office 1",
      :rate => (1 / 2000.0),
      :entity => landlord,
      :give => money(:rub),
      :take => rent
    assert office.save, "Flow is not saved"
    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
                :from => office,
                :to => Deal.income,
                :resource => office.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    forex = Deal.new :tag => "forex deal 4",
      :rate => 34.95,
      :entity => entities(:sbrfbank),
      :give => money(:eur),
      :take => money(:rub)
    assert forex.save, "Flow is not saved"
    f = Fact.new(:amount => 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => (2500.0 * 34.95),
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 600.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => forex,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 100.0 * 34.95,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 2 * 2000.0,
                :day => DateTime.civil(2007, 9, 5, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => office,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 6, 12, 0, 0),
                :from => deals(:bankaccount),
                :to => Deal.income,
                :resource => deals(:bankaccount).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2007, 9, 7, 12, 0, 0),
                :from => Deal.income,
                :to => deals(:bankaccount),
                :resource => deals(:bankaccount).give)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 400.0 * 34.95,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => forex,
                :to => deals(:bankaccount),
                :resource => forex.take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 400.0,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => deals(:bankaccount2),
                :to => Deal.income,
                :resource => deals(:bankaccount2).take)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 400.0,
                :day => DateTime.civil(2007, 9, 10, 12, 0, 0),
                :from => Deal.income,
                :to => forex,
                :resource => forex.give)
    assert f.save, "Fact is not saved"
    t = Txn.new :fact => f
    assert t.save, "Txn is not saved"

    txns = deals(:bankaccount).txns(DateTime.civil(2007, 8, 29, 12, 0, 0),
      DateTime.civil(2007, 8, 29, 12, 0, 0))
    assert_equal 2, txns.count, "Deal txns count is wrong"
    txns.each do |item|
      assert item.instance_of?(Txn), "Wrong txn instance"
      assert (deals(:bankaccount) == item.fact.from or
          deals(:bankaccount) == item.fact.to), "Wrong txn value"
    end

    txns = deals(:bankaccount).txns(DateTime.civil(2007, 8, 30, 12, 0, 0),
      DateTime.civil(2007, 8, 30, 12, 0, 0))
    assert_equal 2, txns.count, "Deal txns count is wrong"
    txns.each do |item|
      assert item.instance_of?(Txn), "Wrong txn instance"
      assert (deals(:bankaccount) == item.fact.from or
          deals(:bankaccount) == item.fact.to), "Wrong txn value"
    end
  end

  private
  def init_facts
    facts = [
      Fact.new(:amount => 100000.0,
              :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
              :from => deals(:equityshare2),
              :to => deals(:bankaccount),
              :resource => deals(:equityshare2).take),
      Fact.new(:amount => 142000.0,
              :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
              :from => deals(:equityshare1),
              :to => deals(:bankaccount),
              :resource => deals(:equityshare1).take),
      Fact.new(:amount => 70000.0,
              :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => deals(:purchase),
              :resource => deals(:bankaccount).take),
      Fact.new(:amount => 1000.0,
              :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
              :from => deals(:forex),
              :to => deals(:bankaccount2),
              :resource => deals(:forex).take),
      Fact.new(:amount => 34950.0,
              :day => DateTime.civil(2007, 8, 30, 12, 0, 0),
              :from => deals(:bankaccount),
              :to => deals(:forex),
              :resource => deals(:bankaccount).take),
      Fact.new(:amount => 1000.0,
              :day => DateTime.civil(2007, 8, 31, 12, 0, 0),
              :from => deals(:bankaccount2),
              :to => deals(:forex2),
              :resource => deals(:bankaccount2).take)
    ]
    facts.each do |f|
      assert f.save, "Fact is not saved"
    end
    facts
  end
end
