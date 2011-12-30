# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.references :money
      t.datetime :day
      t.float :rate
      t.float :diff
    end
    add_index :quotes, [:money_id, :day], :unique => true
  end

  def self.down
    drop_table :quotes
  end
end
