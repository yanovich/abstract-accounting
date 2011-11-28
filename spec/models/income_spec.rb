# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Income do
  it "income" do
    Factory(:income)
    should validate_presence_of :start
    should validate_presence_of :side
    should validate_presence_of :value
    should validate_uniqueness_of :start
    should allow_value(Income::PASSIVE).for(:side)
    should allow_value(Income::ACTIVE).for(:side)
    should_not allow_value("other").for(:side)

    assign_values_through_constructor
  end

  def assign_values_through_constructor
    Income.instance_eval do
      define_method :test= do |value|
        update_value DateTime.now, value
      end
    end
    lambda {
      i = Income.new :test => 10.0
      i.value.should eq(10.0), "Wrong income value"
    }.should_not raise_error
  end
end
