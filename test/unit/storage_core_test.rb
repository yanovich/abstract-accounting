# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class StorageCore < ActiveSupport::TestCase
  test "share 2 to bank" do
    s2tb = Fact.new(:amount => 100000.0,
      :day => DateTime.civil(2007, 8, 29, 12, 0, 0),
      :from => deals(:equityshare2),
      :to => deals(:bankaccount),
      :resource => deals(:equityshare2).take)
    assert s2tb.save, "Fact is not saved"
    assert_equal true,
      check_state(deals(:equityshare2), s2tb.day, 10.0,
        deals(:equityshare2).give)
    assert_equal true,
      check_state(deals(:bankaccount), s2tb.day, 100000.0,
        deals(:bankaccount).take)
  end

  private
  def check_state(deal, day, amount, resource)
    deal_state = deal.state(day)
    if deal_state.nil?
      "#{deal.tag} state not found"
    elsif amount != deal_state.amount
      "#{deal.tag} state amount(#{deal_state.amount}) is not equal to #{amount}"
    elsif resource != deal_state.resource
      "#{deal.tag} invalid state resource"
    else
      true
    end
  end
end
