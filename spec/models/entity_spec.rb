# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe Entity do
  before(:each) do
    Factory(:entity)
  end

  it { should validate_presence_of :tag }
  it { should validate_uniqueness_of :tag }
end
