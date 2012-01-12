# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Person do
  it "should have next behaviour" do
    Person.create!(:first_name => "Sergey", :second_name => "Sergeev",
                   :birthday => Date.today, :place_of_birth => "Minsk")
    should validate_presence_of :first_name
    should validate_presence_of :second_name
    should validate_presence_of :birthday
    should validate_presence_of :place_of_birth
    should validate_uniqueness_of(:first_name).scoped_to(:second_name)
    should have_many Person.versions_association_name
  end
end
