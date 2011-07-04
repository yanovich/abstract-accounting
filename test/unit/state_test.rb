# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class StateTest < ActiveSupport::TestCase
  test "Store states" do
    s = State.new
    assert_equal "active", s.side, "State is not initialized"
    assert s.invalid?, "Empty state is valid"
    s.deal = Deal.first
    assert s.invalid?, "State with deal is valid"
    s.start = DateTime.civil(2011, 1, 8)
    s.amount = 5000
    s.side = "passive"
    assert s.valid?, "State is invalid"
    s.side = "passive2"
    assert s.invalid?, "State with wrong side is valid"
    s.side = "active"
    assert s.save, "State is not saved"
    s.destroy
    assert_equal 0, State.all.count, "State is not deleted"
  end
end
