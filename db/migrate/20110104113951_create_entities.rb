# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateEntities < ActiveRecord::Migration
  def self.up
    create_table :entities do |t|
      t.string :tag
    end
  end

  def self.down
    drop_table :entities
  end
end

# vim: ts=2 sts=2 sw=2 et:
