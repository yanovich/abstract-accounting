# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Entity < ActiveRecord::Base
  has_paper_trail

  validates_presence_of :tag
  validates_uniqueness_of :tag
  has_many :deals
end

# vim: ts=2 sts=2 sw=2 et:
