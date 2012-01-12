# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe LegalEntity do
  it "should have next behaviour" do
    LegalEntity.create!(:name => "Somename", :country => Factory(:country),
                        :identifier_name => "VATIN",
                        :identifier_value => "1234567890")
    should validate_presence_of :name
    should validate_presence_of :country_id
    should validate_presence_of :identifier_name
    should validate_presence_of :identifier_value
    should validate_uniqueness_of(:name).scoped_to(:country_id)
    should belong_to :country
    should belong_to :detail
    should have_many LegalEntity.versions_association_name
  end
end
