# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe EstimateElement do
  it "should have next behaviour" do
    EstimateElement.create!(:estimate_id => 1, :bom_id => 1, :amount => 10)
    should validate_presence_of :estimate_id
    should validate_presence_of :bom_id
    should validate_presence_of :amount
    should validate_uniqueness_of(:bom_id).scoped_to(:estimate_id)
    should belong_to :estimate
    should belong_to(:bom).class_name(BoM)
    should have_many EstimateElement.versions_association_name
  end
end
