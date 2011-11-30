# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe User do
  it "should have next behaviour" do
    Factory(:user)
    should validate_presence_of :email
    should validate_presence_of :entity_id
    should validate_uniqueness_of(:email).scoped_to(:entity_id)
    should validate_format_of(:email).not_with("test@test").with_message(/invalid/)
    should belong_to(:entity)
    should have_many User.versions_association_name
  end
end
