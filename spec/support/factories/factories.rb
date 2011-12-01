# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

FactoryGirl.define do
  factory :entity do |e|
    e.sequence(:tag) { |n| "entity#{n}" }
  end

  factory :asset do |a|
    a.sequence(:tag) { |n| "asset#{n}" }
    a.sequence(:mu) { |n| "mu#{n}" }
  end

  factory :money do |m|
    m.sequence(:alpha_code) { |n| "MN#{n}" }
    m.sequence(:num_code) { |n| n }
  end

  factory :chart do |c|
    c.currency { |chart| chart.association(:money) }
  end

  factory :deal do |d|
    d.sequence(:tag) { |n| "deal#{n}" }
    d.give { |deal| deal.association(:asset) }
    d.take { |deal| deal.association(:asset) }
    d.entity { |deal| deal.association(:entity) }
    d.rate 1.0
  end

  factory :state do |s|
    s.start DateTime.now
    s.amount 1.0
    s.side StateAction::ACTIVE
    s.deal { |state| state.association(:deal) }
  end

  factory :balance do |b|
    b.start DateTime.now
    b.amount 1.0
    b.value 1.0
    b.side Balance::ACTIVE
    b.deal { |balance| balance.association(:deal) }
  end

  factory :fact do |f|
    f.day DateTime.civil(DateTime.now.year, DateTime.now.month, DateTime.now.day, 12, 0, 0)
    f.amount 1.0
    f.resource { |fact| fact.association(:money) }
    f.from { |fact| fact.association(:deal, :take => fact.resource) }
    f.to { |fact| fact.association(:deal, :give => fact.resource) }
  end

  factory :txn do |t|
    t.fact { |txn| txn.association(:fact) }
  end

  factory :income do |i|
    i.start DateTime.now
    i.side Income::PASSIVE
    i.value 1.0
  end

  factory :quote do |q|
    q.money { |quote| quote.association(:money) }
    q.rate 1.0
    q.day DateTime.now
  end

  factory :rule do |r|
    r.sequence(:tag) { |n| "rule#{n}" }
    r.deal { |rule| rule.association(:deal) }
    r.from { |rule| rule.association(:deal) }
    r.to { |rule| rule.association(:deal) }
    r.fact_side false
    r.change_side true
    r.rate 1.0
  end

  factory :price do |p|
    p.resource { |price| price.association(:asset) }
    p.rate 10.0
    p.price_list_id 1
  end

  factory :price_list do |pl|
    pl.resource { |plist| plist.association(:asset) }
    pl.date Date.new(2012, 1, 1)
    pl.tab "sometab"
  end

  factory :bo_m do |bom|
    bom.resource { |b| b.association(:asset) }
    bom.tab "sometab"
  end

  factory :bo_m_element do |be|
    be.resource { |element| element.association(:asset) }
    be.rate 0.45
    be.bom_id 1
  end

  factory :mu do |m|
    m.sequence(:tag) { |n| "mu#{n}" }
  end

  factory :country do |c|
    c.sequence(:tag) { |n| "Country#{n}" }
  end

  factory :person do |p|
    p.sequence(:first_name) { |n| "FirstName#{n}" }
    p.sequence(:second_name) { |n| "SecondName#{n}" }
    p.birthday Date.today
    p.place_of_birth "Minsk"
  end

  factory :user do |u|
    u.sequence(:email) { |n| "user#{n}@aasii.org" }
    u.password "secret"
    u.password_confirmation "secret"
    u.entity { |user| user.association(:entity) }
    u.sequence(:reset_password_token) { |n| "anything#{n}" }
  end
end
