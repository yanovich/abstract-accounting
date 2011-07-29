# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class IncomeTest < ActiveSupport::TestCase
  test "income should be saved" do
    i = Income.new
    assert i.invalid?, "Invalid income"
    assert_equal 0.0, i.value, "Wrong income value"
    assert_equal Income::PASSIVE, i.side, "Wrong income side"
    i.start = DateTime.civil(2011, 9, 18)
    assert i.valid?, "Invalid income"
    i.side = "asdasd"
    assert i.invalid?, "Invalid income"
    i.side = Income::PASSIVE
    assert i.save, "Income is not saved"
    i = Income.new
    i.start = DateTime.civil(2011, 9, 19)
    assert i.valid?, "Valid income"
    i.start = DateTime.civil(2011, 9, 18)
    assert i.invalid?, "Invalid income"
  end

  test "assign values through constructor" do
    Income.instance_eval do
      define_method :test= do |value|
        update_value DateTime.now, value
      end
    end
    assert_nothing_raised do
      i = Income.new :test => 10.0
      assert_equal 10.0, i.value, "Wrong income value"
    end
  end
end
