# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateIncomes < ActiveRecord::Migration
  def self.up
    create_table :incomes do |t|
      t.datetime :start
      t.string :side
      t.float :value
      t.datetime :paid
    end
    add_index :incomes, :start, :unique => true
  end

  def self.down
    drop_table :incomes
  end
end
