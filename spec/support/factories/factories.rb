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
end
