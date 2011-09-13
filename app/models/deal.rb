# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Deal < ActiveRecord::Base
  validates_presence_of :tag
  validates_presence_of :rate
  belongs_to :entity
  belongs_to :give, :polymorphic => true
  belongs_to :take, :polymorphic => true
end

# vim: ts=2 sts=2 sw=2 et:
