# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe IdentityDocument do
  it "should have next behaviour" do
    IdentityDocument.create!(:country => Factory(:country),
      :number => "DAS", :date_of_issue => Date.today,
      :authority => "Minsk", :person => Factory(:person))
    should validate_presence_of :country_id
    should validate_presence_of :number
    should validate_presence_of :date_of_issue
    should validate_presence_of :authority
    should validate_presence_of :person_id
    should validate_uniqueness_of(:number).scoped_to(:country_id)
    should belong_to :country
    should belong_to :person
    should have_many IdentityDocument.versions_association_name
  end
end
