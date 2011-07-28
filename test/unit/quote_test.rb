# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class QuoteTest < ActiveSupport::TestCase
  test "quote should save" do
    cf = Money.new :alpha_code => "cf", :num_code => 1
    cf.save

    q = Quote.new :money => cf,
      :rate => 1.0,
      :day => DateTime.civil(2008, 3, 24, 12, 0, 0)
    assert_equal 0.0, q.diff, "Quote diff is not initialized"
    assert q.valid?, "Quote is not valid"
    assert q.save, "Quote is not saved"
    assert_equal 0.0, Quote.find(q.id).diff, "Quote diff is not saved"

    q = Quote.new :money => cf,
      :rate => 1.0,
      :day => DateTime.civil(2008, 3, 24, 12, 0, 0)
    assert q.invalid?, "Quote validate with not unique money"

    q = Quote.new :money => cf,
      :rate => 1.0,
      :day => DateTime.civil(2008, 3, 25, 12, 0, 0)
    assert q.valid?, "Quote is not valid"
  end
end
