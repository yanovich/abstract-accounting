# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Description do
  it "should have next behaviour" do
    Description.create!(:description => "das", :item => Factory(:entity))
    should validate_presence_of :description
    should validate_presence_of :item_id
    should validate_uniqueness_of(:item_id).scoped_to(:item_type)
    should belong_to(:item)
    should have_many Description.versions_association_name
  end
end
