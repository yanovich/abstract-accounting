# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class RuleTest < ActiveSupport::TestCase
  test "rule" do
    rule_must_be_saved
    rule_workflow
    rule_filter_attributes
  end

  private
  def rule_must_be_saved
    r = Rule.new
    assert r.invalid?, "Empty rule valid"
    r.tag = "test rule"
    assert r.invalid?, "Rule should be invalid"
    r.deal = deals(:equityshare1)
    assert r.invalid?, "Rule should be invalid"
    r.rate = 1.0
    assert r.invalid?, "Rule should be invalid"
    r.change_side = true
    r.fact_side = false
    r.from = deals(:equityshare2)
    assert r.invalid?, "Rule should be invalid"
    r.to = deals(:bankaccount)
    assert r.valid?, "Rule is not valid"
    assert r.save, "Rule is not saved"
  end

  def rule_workflow
    x = Asset.new :tag => "resource x"
    assert x.save, "Asset is not saved"
    y = Asset.new :tag => "resource y"
    assert y.save, "Asset is not saved"
    keeper = Entity.new :tag => "keeper"
    assert keeper.save, "Entity is not saved"
    shipment = Asset.new :tag => "shipment"
    assert shipment.save, "Asset is not saved"
    supplier = Entity.new :tag => "supplier"
    assert supplier.save, "Entity is not saved"
    purchase_x = Deal.new :entity => supplier, :give => money(:rub),
      :take => x, :rate => (1.0 / 100.0), :tag => "purchase 1"
    assert purchase_x.save,"Dealisnot saved"
    purchase_y = Deal.new :entity => supplier, :give => money(:rub),
      :take => y, :rate => (1.0 / 150.0), :tag => "purchase 2"
    assert purchase_y.save, "Deal is not saved"
    storage_x = Deal.new :entity => keeper, :give => x,
      :take => x, :rate => 1.0, :tag => "storage 1"
    assert storage_x.save, "Deal is not saved"
    storage_y = Deal.new :entity => keeper, :give => y,
      :take => y, :rate => 1.0, :tag => "storage 2"
    assert storage_y.save, "Deal is not saved"
    sale_x = Deal.new :entity => supplier, :give => x,
      :take => money(:rub), :rate => 120.0, :tag => "sale 1"
    assert sale_x.save, "Deal is not saved"
    sale_y = Deal.new :entity => supplier, :give => y,
      :take => money(:rub), :rate => 160.0, :tag => "sale 2"
    assert sale_y.save, "Deal is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
                :from => purchase_x,
                :to => storage_x,
                :resource => purchase_x.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    f = Fact.new(:amount => 50.0,
                :day => DateTime.civil(2008, 9, 16, 12, 0, 0),
                :from => purchase_y,
                :to => storage_y,
                :resource => purchase_y.take)
    assert f.save, "Fact is not saved"
    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    assert_equal 4, Balance.open.count, "Wrong open balances count"
    b = purchase_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = purchase_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 7500.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = storage_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = storage_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 50.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"

    shipment_deal = Deal.new :tag => "shipment 1", :rate => 1.0,
      :entity => supplier, :give => shipment, :take => shipment,
      :isOffBalance => true
    assert shipment_deal.save, "Deal is not saved"
    assert_equal true, Deal.find(shipment_deal.id).isOffBalance,
      "Wrong saved value for is off balance"

    shipment_deal.rules.create :tag => "shipment1.rule1",
      :from => storage_x, :to => sale_x, :fact_side => false,
      :change_side => true, :rate => 27.0

    assert_equal 2, Rule.all.count, "Rule count is wrong"

    shipment_deal.rules.create :tag => "shipment1.rule2",
      :from => storage_y, :to => sale_y, :fact_side => false,
      :change_side => true, :rate => 42.0

    assert_equal 3, Rule.all.count, "Rule count is wrong"

    f = Fact.new(:amount => 1.0,
                :day => DateTime.civil(2008, 9, 22, 12, 0, 0),
                :from => nil,
                :to => shipment_deal,
                :resource => shipment_deal.give)
    assert f.save, "Fact is not saved"

    assert_equal 7, State.open.count, "Wrong open states count"
    s = purchase_x.state
    assert !s.nil?, "State is nil"
    assert_equal 5000.0, s.amount, "State amount is wrong"

    s = purchase_y.state
    assert !s.nil?, "State is nil"
    assert_equal 7500.0, s.amount, "State amount is wrong"

    s = storage_x.state
    assert !s.nil?, "State is nil"
    assert_equal 23.0, s.amount, "State amount is wrong"

    s = storage_y.state
    assert !s.nil?, "State is nil"
    assert_equal 8.0, s.amount, "State amount is wrong"

    s = sale_x.state
    assert !s.nil?, "State is nil"
    assert_equal (120.0 * 27.0).accounting_norm, s.amount, "State amount is wrong"

    s = sale_y.state
    assert !s.nil?, "State is nil"
    assert_equal (160.0 * 42.0).accounting_norm, s.amount, "State amount is wrong"

    s = shipment_deal.state
    assert !s.nil?, "State is nil"
    assert_equal 1.0, s.amount, "State amount is wrong"

    t = Txn.new(:fact => f)
    assert t.save, "Txn is not saved"
    assert_equal 6, Balance.open.count, "Wrong open balances count"
    b = purchase_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 5000.0, b.amount, "Wrong balance amount"
    assert_equal 5000.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = purchase_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 7500.0, b.amount, "Wrong balance amount"
    assert_equal 7500.0, b.value, "Wrong balance value"
    assert_equal Balance::PASSIVE, b.side, "Wrong balance side"
    b = storage_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 23.0, b.amount, "Wrong balance amount"
    assert_equal 2300.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = storage_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 8.0, b.amount, "Wrong balance amount"
    assert_equal 1200.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = sale_x.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 3240.0, b.amount, "Wrong balance amount"
    assert_equal 3240.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
    b = sale_y.balance
    assert !b.nil?, "Balance is nil"
    assert_equal 6720.0, b.amount, "Wrong balance amount"
    assert_equal 6720.0, b.value, "Wrong balance value"
    assert_equal Balance::ACTIVE, b.side, "Wrong balance side"
  end

  def rule_filter_attributes
    storekeeper = Entity.new :tag => "SONY VAIO Storekeeper"
    assert storekeeper.save, "Entity is not saved"
    svwarehouse = Deal.new :tag => "sonyvaio warehouse",
                           :rate => 1.0,
                           :entity => storekeeper,
                           :give => assets(:sonyvaio),
                           :take => assets(:sonyvaio)
    assert svwarehouse.save, "Deal is not saved"
    buyer = Entity.new :tag => "SONY VAIO Buyer"
    assert buyer.save, "Entity is not saved"
    svsale = Deal.new :tag => "sony vaio sale",
                      :rate => 80000,
                      :entity => buyer,
                      :give => assets(:sonyvaio),
                      :take => money(:rub)
    assert svsale.save, "Deal is not saved"

    svwarehouse.rules.create :tag => "purchase payment",
                             :from => deals(:bankaccount),
                             :to => deals(:purchase),
                             :fact_side => false,
                             :change_side => true,
                             :rate => (1 / deals(:purchase).rate).accounting_norm

    assert_equal 9, State.count, "Wrong state count"
    fact = Fact.new :day => DateTime.civil(2011, 9, 1, 12, 0, 0),
                    :amount => 300,
                    :from => deals(:purchase),
                    :to => svwarehouse,
                    :resource => svwarehouse.give
    assert fact.save, "Fact is not saved"
    assert_equal 11, State.count, "Wrong state count"
    assert_equal 9, State.open.count, "Wrong open state count"
    state = deals(:purchase).state
    assert state.nil?, "Purchase state is not nil"
    state = deals(:bankaccount).state
    assert !state.nil?, "Bankaccount state is not nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal (1 / deals(:purchase).rate).accounting_norm * fact.amount, state.amount, "Wrong state amount"
    state = svwarehouse.state
    assert !state.nil?, "Warehouse bank state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount, state.amount, "Wrong state amount"

    buyerbank = Deal.new :tag => "sony vaio buyerbank",
                         :rate => 1.0,
                         :entity => entities(:sbrfbank),
                         :give => money(:rub),
                         :take => money(:rub)
    assert buyerbank.save, "Deal is not saved"

    svsale.rules.create :tag => "sale payment",
                        :from => buyerbank,
                        :to => deals(:bankaccount),
                        :fact_side => false,
                        :change_side => true,
                        :rate => 1.0

    assert_equal 9, State.open.count, "Wrong state count"
    fact = Fact.new :day => DateTime.civil(2011, 9, 2, 12, 0, 0),
                    :amount => 300,
                    :from => deals(:purchase),
                    :to => svsale,
                    :resource => svsale.give
    assert fact.save, "Fact is not saved"
    assert_equal 15, State.count, "Wrong state count"
    assert_equal 12, State.open.count, "Wrong open state count"
    state = deals(:purchase).state
    assert !state.nil?, "Purchase state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal (fact.amount / deals(:purchase).rate).accounting_norm, state.amount, "Wrong state amount"
    state = deals(:bankaccount).state
    assert !state.nil?, "Bankaccount state is not nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount * svsale.rate - ((1 / deals(:purchase).rate).accounting_norm * 300),
                 state.amount, "Wrong state amount"
    state = svwarehouse.state
    assert !state.nil?, "Warehouse bank state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount, state.amount, "Wrong state amount"
    state = buyerbank.state
    assert !state.nil?, "Buyer bank state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal fact.amount * svsale.rate, state.amount, "Wrong state amount"
    state = svsale.state
    assert !state.nil?, "Sale state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount * svsale.rate, state.amount, "Wrong state amount"

    svsale2 = Deal.new :tag => "sony vaio sale2",
                       :rate => 70000,
                       :entity => buyer,
                       :give => assets(:sonyvaio),
                       :take => money(:rub)
    assert svsale2.save, "Deal is not saved"

    deals(:purchase).rules.create :tag => "sale payment",
                                  :from => svsale2,
                                  :to => deals(:bankaccount),
                                  :fact_side => true,
                                  :change_side => true,
                                  :rate => 1.0

    assert_equal 12, State.open.count, "Wrong state count"
    fact = Fact.new :day => DateTime.civil(2011, 9, 2, 12, 0, 0),
                    :amount => 300,
                    :from => deals(:purchase),
                    :to => svsale2,
                    :resource => svsale2.give
    assert fact.save, "Fact is not saved"
    assert_equal 12, State.open.count, "Wrong open state count"
    state = deals(:purchase).state
    assert !state.nil?, "Purchase state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal 2 * (fact.amount / deals(:purchase).rate).accounting_norm, state.amount, "Wrong state amount"
    state = deals(:bankaccount).state
    assert !state.nil?, "Bankaccount state is not nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount * svsale.rate, state.amount, "Wrong state amount"
    state = svwarehouse.state
    assert !state.nil?, "Warehouse bank state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount, state.amount, "Wrong state amount"
    state = buyerbank.state
    assert !state.nil?, "Buyer bank state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal fact.amount * svsale.rate, state.amount, "Wrong state amount"
    state = svsale.state
    assert !state.nil?, "Sale state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount * svsale.rate, state.amount, "Wrong state amount"
    state = svsale2.state
    assert state.nil?, "Sale state is not nil"

    galaxy = Asset.new :tag => "Samsung Galaxy"
    assert galaxy.save, "Galaxy is not saved"
    purchase_g = Deal.new :tag => "purchase galaxy",
                       :rate => 0.0002,
                       :entity => entities(:equipmentsupl),
                       :give => money(:rub),
                       :take => galaxy
    assert purchase_g.save, "Deal is not saved"
    sale_g = Deal.new :tag => "galaxy sale",
                       :rate => 5000,
                       :entity => buyer,
                       :give => galaxy,
                       :take => money(:rub)
    assert sale_g.save, "Deal is not saved"

    fact = Fact.new :day => DateTime.civil(2011, 9, 3, 12, 0, 0),
                    :amount => 300,
                    :from => purchase_g,
                    :to => sale_g,
                    :resource => sale_g.give
    assert fact.save, "Fact is not saved"
    state = purchase_g.state
    assert !state.nil?, "Buyer bank state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal fact.amount / purchase_g.rate, state.amount, "Wrong state amount"
    state = sale_g.state
    assert !state.nil?, "Sale state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal fact.amount * sale_g.rate, state.amount, "Wrong state amount"

    sale_g.rules.create :tag => "sale payment",
                        :from => deals(:bankaccount),
                        :to => purchase_g,
                        :fact_side => true,
                        :change_side => true,
                        :rate => 5000

    fact = Fact.new :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
                    :amount => sale_g.rate * 200,
                    :from => sale_g,
                    :to => deals(:bankaccount),
                    :resource => deals(:bankaccount).give
    assert fact.save, "Fact is not saved"
    state = purchase_g.state
    assert !state.nil?, "Buyer bank state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal 300 / purchase_g.rate, state.amount, "Wrong state amount"
    state = sale_g.state
    assert !state.nil?, "Sale state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal 100 * sale_g.rate, state.amount, "Wrong state amount"

    fact = Fact.new :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
                    :amount => sale_g.rate * 200,
                    :from => sale_g,
                    :to => deals(:bankaccount),
                    :resource => deals(:bankaccount).give
    assert fact.save, "Fact is not saved"
    state = purchase_g.state
    assert !state.nil?, "Buyer bank state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal 200 / purchase_g.rate, state.amount, "Wrong state amount"
    state = sale_g.state
    assert !state.nil?, "Sale state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal 100, state.amount, "Wrong state amount"

    nokia = Asset.new :tag => "Nokia 2310"
    assert nokia.save, "Asset is not saved"
    purchase_n = Deal.new :tag => "purchase nokia",
                       :rate => 0.00033,
                       :entity => entities(:equipmentsupl),
                       :give => money(:rub),
                       :take => nokia
    assert purchase_n.save, "Deal is not saved"
    sale_n = Deal.new :tag => "nokia sale",
                       :rate => 3000,
                       :entity => buyer,
                       :give => nokia,
                       :take => money(:rub)
    assert sale_n.save, "Deal is not saved"

    fact = Fact.new :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
                    :amount => (200 / purchase_n.rate).accounting_norm,
                    :from => deals(:bankaccount),
                    :to => purchase_n,
                    :resource => purchase_n.give
    assert fact.save, "Fact is not saved"
    state = purchase_n.state
    assert !state.nil?, "Purchase state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal 200.0, state.amount, "Wrong state amount"

    purchase_n.rules.create :tag => "purchase payment",
                            :from => sale_n,
                            :to => deals(:bankaccount),
                            :fact_side => true,
                            :change_side => false,
                            :rate => 3000

    fact = Fact.new :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
                    :amount => 100,
                    :from => purchase_n,
                    :to => sale_n,
                    :resource => sale_n.give
    assert fact.save, "Fact is not saved"
    state = purchase_n.state
    assert !state.nil?, "Purchase state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal 100, state.amount, "Wrong state amount"
    state = sale_n.state
    assert state.nil?, "Sale state is not nil"

    nokia33 = Asset.new :tag => "Nokia 3310"
    assert nokia33.save, "Asset is not saved"
    purchase_n33 = Deal.new :tag => "purchase nokia 3310",
                       :rate => 0.00025,
                       :entity => entities(:equipmentsupl),
                       :give => money(:rub),
                       :take => nokia33
    assert purchase_n33.save, "Deal is not saved"
    sale_n33 = Deal.new :tag => "nokia 3310 sale",
                       :rate => 4000,
                       :entity => buyer,
                       :give => nokia33,
                       :take => money(:rub)
    assert sale_n33.save, "Deal is not saved"

    sale_n33.rules.create :tag => "purchase payment 3310",
                          :from => deals(:bankaccount),
                          :to => purchase_n33,
                          :fact_side => false,
                          :change_side => false,
                          :rate => 4000

    fact = Fact.new :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
                    :amount => 100,
                    :from => purchase_n33,
                    :to => sale_n33,
                    :resource => sale_n33.give
    assert fact.save, "Fact is not saved"
    state = purchase_n33.state
    assert !state.nil?, "Purchase state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal 100 / purchase_n33.rate, state.amount, "Wrong state amount"
    state = sale_n33.state
    assert !state.nil?, "Sale state is nil"
    assert_equal State::ACTIVE, state.side, "Wrong state side"
    assert_equal 100 * sale_n33.rate, state.amount, "Wrong state amount"

    sale_n33.rules.clear
    sale_n33.rules.create :tag => "purchase payment 3310",
                          :from => deals(:bankaccount),
                          :to => purchase_n33,
                          :fact_side => true,
                          :change_side => false,
                          :rate => 1.0


    fact = Fact.new :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
                    :amount => 200 * sale_n33.rate,
                    :from => sale_n33,
                    :to => deals(:bankaccount),
                    :resource => sale_n33.take
    assert fact.save, "Fact is not saved"
    state = purchase_n33.state
    assert state.nil?, "Purchase state is not nil"
    state = sale_n33.state
    assert !state.nil?, "Sale state is nil"
    assert_equal State::PASSIVE, state.side, "Wrong state side"
    assert_equal 100, state.amount, "Wrong state amount"

    alcatel = Asset.new :tag => "Alcatel"
    assert alcatel.save, "Asset is not saved"
    purchase_a = Deal.new :tag => "purchase alcatel",
                       :rate => 0.0001,
                       :entity => entities(:equipmentsupl),
                       :give => money(:rub),
                       :take => alcatel
    assert purchase_a.save, "Deal is not saved"
    sale_a = Deal.new :tag => "alcatel sale",
                       :rate => 1000,
                       :entity => buyer,
                       :give => alcatel,
                       :take => money(:rub)
    assert sale_a.save, "Deal is not saved"

    purchase_a.rules.create :tag => "purchase payment",
                            :from => deals(:bankaccount),
                            :to => purchase_a,
                            :fact_side => true,
                            :change_side => true,
                            :rate => 1.0

    sale_a.rules.create :tag => "sale payment",
                        :from => sale_a,
                        :to => deals(:bankaccount),
                        :fact_side => false,
                        :change_side => true,
                        :rate => 1.0

    fact = Fact.new :day => DateTime.civil(2011, 9, 4, 12, 0, 0),
                    :amount => 100,
                    :from => purchase_a,
                    :to => sale_a,
                    :resource => sale_a.give
    assert fact.save, "Fact is not saved"
    state = purchase_a.state
    assert state.nil?, "Purchase state is not nil"
    state = sale_a.state
    assert state.nil?, "Sale state is not nil"
  end
end
