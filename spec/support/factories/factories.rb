# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
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
end
