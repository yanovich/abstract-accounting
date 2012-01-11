# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Description < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :description, :item_id
  validates_uniqueness_of :item_id, :scope => :item_type
  belongs_to :item, :polymorphic => true
end
