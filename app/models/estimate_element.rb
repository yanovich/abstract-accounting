# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class EstimateElement < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :amount, :bom_id, :estimate_id
  validates_uniqueness_of :bom_id, :scope => :estimate_id
  belongs_to :bom, :class_name => "BoM"
  belongs_to :estimate
end
