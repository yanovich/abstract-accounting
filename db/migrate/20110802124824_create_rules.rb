# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.references :deal
      t.boolean :fact_side
      t.boolean :change_side
      t.float :rate
      t.string :tag
      t.references :from
      t.references :to
    end
  end

  def self.down
    drop_table :rules
  end
end
