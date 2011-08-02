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
  test "rule must be saved" do
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
end
