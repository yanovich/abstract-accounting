# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Fact do
  it "should have next behaviour" do
    should validate_presence_of :day
    should validate_presence_of :amount
    should validate_presence_of :resource_id
    should validate_presence_of :to_deal_id
    should belong_to :resource
    should belong_to :from
    should belong_to :to
    should have_one :txn
    should have_many Fact.versions_association_name
    Factory.build(:fact).should be_valid
    Factory.build(:fact, :from => Factory(:deal)).should_not be_valid
  end
end
