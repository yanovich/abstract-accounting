# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Estimate do
  it "should have next behaviour" do
    should validate_presence_of :entity_id
    should validate_presence_of :price_list_id
    should validate_presence_of :deal_id
    should belong_to(:deal)
    should belong_to(:entity)
    should belong_to(:price_list)
    should have_many Estimate.versions_association_name
  end
end
