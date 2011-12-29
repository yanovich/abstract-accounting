# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe State do
  it "should have next behaviour" do
    Factory(:state)
    should validate_presence_of :amount
    should validate_presence_of :start
    should validate_presence_of :side
    should validate_presence_of :deal_id
    should allow_value(State::PASSIVE).for(:side)
    should allow_value(State::ACTIVE).for(:side)
    should_not allow_value("some value").for(:side)
    should_not allow_value(22).for(:side)
    should belong_to :deal
    should have_many State.versions_association_name
  end
end
