# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Income do
  it "should have next behaviour" do
    Factory(:income)
    should validate_presence_of :start
    should validate_presence_of :side
    should validate_presence_of :value
    should validate_uniqueness_of :start
    should allow_value(Income::PASSIVE).for(:side)
    should allow_value(Income::ACTIVE).for(:side)
    should_not allow_value("other").for(:side)
    should have_many Income.versions_association_name
  end
end
