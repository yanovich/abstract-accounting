# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class FactTest < ActiveSupport::TestCase
  test "Store facts" do
    fact = Fact.new :amount => 100000.0,
      :day => DateTime.civil(2007, 8, 27, 12, 0, 0)
    fact.to = deals(:equityshare1)
    fact.from = deals(:equityshare2)
    fact.resource = fact.from.take
    assert !fact.valid?, "Fact should not be valid"
    fact.to = deals(:bankaccount)
    assert fact.save, "Fact not saved"
  end
end
