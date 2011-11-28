# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Money do
  it "money" do
    Factory(:money)
    should validate_presence_of :num_code
    should validate_presence_of :alpha_code
    should validate_uniqueness_of :num_code
    should validate_uniqueness_of :alpha_code
    should have_many :deal_gives
    should have_many :deal_takes
    should have_many :quotes
  end
end
