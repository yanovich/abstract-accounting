# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class TxnTest < ActiveSupport::TestCase
  test "txn should save" do
    fact = Fact.new :amount => 100000.0,
      :day => DateTime.civil(2007, 8, 27, 12, 0, 0)
    fact.to = deals(:equityshare1)
    fact.from = deals(:equityshare2)
    fact.resource = fact.from.take
    assert fact.invalid?, "Fact should not be valid"
    fact.to = deals(:bankaccount)
    assert fact.save, "Fact not saved"
    t = Txn.new
    assert t.invalid?, "Empty transaction saved"
    t.fact = fact
    assert t.invalid?, "Txn with value and status is not valid"
    t.value = 100.0
    assert t.invalid?, "Txn with status is not valid"
    t.status = 0
    assert t.valid?, "Txn is not valid"
    assert t.save, "Txn is not saved"
    t2 = Txn.new
    t2.fact = fact
    t2.value = 12.0
    t2.status = 1
    assert t2.invalid?, "Txn with unique fact is not valid"
  end
end
