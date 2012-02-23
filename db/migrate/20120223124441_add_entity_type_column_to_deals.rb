# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class AddEntityTypeColumnToDeals < ActiveRecord::Migration
  def change
    remove_index :deals, :column => [:entity_id, :tag]
    add_column :deals, :entity_type, :string
    add_index :deals, [:entity_id, :entity_type, :tag], :unique => true
  end
end
