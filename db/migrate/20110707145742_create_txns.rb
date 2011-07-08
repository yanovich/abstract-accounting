# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateTxns < ActiveRecord::Migration
  def self.up
    create_table :txns do |t|
      t.references :fact
      t.float :value
      t.integer :status
      t.float :earnings
    end
    add_index :txns, :fact_id, :unique => true
  end

  def self.down
    drop_table :txns
  end
end
