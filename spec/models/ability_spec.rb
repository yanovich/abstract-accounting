# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'
require "cancan/matchers"

describe Ability do
  it "should have next behaviour" do
    user = Factory(:user)
    Ability.new(user).should_not be_able_to(:manage, :all)
    Ability.new(nil).should_not be_able_to(:manage, :all)
    Ability.new(RootUser.new).should be_able_to(:manage, :all)
    Ability.new(user).should be_able_to(:read, :all)
    Ability.new(nil).should_not be_able_to(:read, :all)
  end
end
