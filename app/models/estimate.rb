# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Estimate < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :entity_id, :price_list_id, :deal_id
  belongs_to :entity
  belongs_to :price_list
  belongs_to :deal
end
