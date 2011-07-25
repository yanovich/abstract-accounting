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

    assert_equal 1, Income.all.count, "Income count is wrong"
    profit = (1000.0 * (deals(:forex2).rate -
      (1/deals(:forex).rate))).accounting_norm
    assert_equal profit, Income.all.first.value, "Invalid income value"
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
