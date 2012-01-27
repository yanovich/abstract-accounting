# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Catalog do
  it "should have next behaviour" do
    Catalog.create! :tag => "catalog0"
    should validate_presence_of :tag
    should validate_uniqueness_of(:tag).scoped_to(:parent_id)
    should belong_to(:parent).class_name(Catalog)
    should have_many(:subcatalogs).class_name(Catalog)
    should have_many Catalog.versions_association_name
  end
end
