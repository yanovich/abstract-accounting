# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Quote do
  it "quote" do
    Factory(:quote)
    should validate_presence_of :money_id
    should validate_presence_of :day
    should validate_presence_of :rate
    should validate_presence_of :diff
    should validate_uniqueness_of(:day).scoped_to(:money_id)
    should belong_to :money
    should have_many Quote.versions_association_name
  end
end
