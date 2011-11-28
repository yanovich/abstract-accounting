# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Balance do
  it "should have next behaviour" do
    Factory(:balance)
    should validate_presence_of :amount
    should validate_presence_of :value
    should validate_presence_of :start
    should validate_presence_of :side
    should validate_presence_of :deal_id
    should allow_value(Balance::PASSIVE).for(:side)
    should allow_value(Balance::ACTIVE).for(:side)
    should_not allow_value("some value").for(:side)
    should_not allow_value(22).for(:side)
    should validate_uniqueness_of(:start).scoped_to(:deal_id)
    should belong_to :deal
  end
end
