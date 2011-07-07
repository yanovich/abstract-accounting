# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateBalances < ActiveRecord::Migration
  def self.up
    create_table :balances do |t|
      t.references :deal
      t.string :side
      t.float :amount
      t.float :value
      t.datetime :start
      t.datetime :paid
    end
    add_index :balances, [:deal_id, :start], :unique => true
  end

  def self.down
    drop_table :balances
  end
end
