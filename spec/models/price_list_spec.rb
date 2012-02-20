# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe PriceList do
  it "should have next behaviour" do
    should validate_presence_of :resource_id
    should validate_presence_of :date
    should validate_presence_of :tab
    should belong_to(:resource).class_name(Asset)
    should have_many(PriceList.versions_association_name)
    should have_many(:items).class_name(Price)
    should have_and_belong_to_many(:catalogs)
  end
end
