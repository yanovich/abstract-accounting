# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Chart < ActiveRecord::Base
  has_paper_trail

  belongs_to :currency, :class_name => 'Money'
  validates_presence_of :currency_id
  validates_uniqueness_of :currency_id
end
