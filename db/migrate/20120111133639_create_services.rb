# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details
class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :tag
      t.string :mu
      t.references :detailed
    end
    add_index :services, :detailed_id
    add_index :services, [:tag, :mu], :unique => true
  end
end
