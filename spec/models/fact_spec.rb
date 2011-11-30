# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Fact do
  before(:all) do
    DatabaseCleaner.start
  end

  after(:all) do
    DatabaseCleaner.clean
  end
  it "should have next behaviour" do
    should validate_presence_of :day
    should validate_presence_of :amount
    should validate_presence_of :resource_id
    should validate_presence_of :to_deal_id
    should belong_to :resource
    should belong_to :from
    should belong_to :to
    should have_one :txn
    Factory.build(:fact).should be_valid
    Factory.build(:fact, :from => Factory(:deal)).should_not be_valid
  end
end
