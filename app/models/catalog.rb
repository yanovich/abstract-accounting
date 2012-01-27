# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Catalog < ActiveRecord::Base
  has_paper_trail

  validates :tag, :presence => true
  validates_uniqueness_of :tag, :scope => :parent_id
  belongs_to :parent, :class_name => "Catalog"
  has_many :subcatalogs,  :class_name => "Catalog", :foreign_key => :parent_id
end
