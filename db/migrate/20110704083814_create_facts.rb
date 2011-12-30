# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateFacts < ActiveRecord::Migration
  def self.up
    create_table :facts do |t|
      t.datetime :day
      t.float :amount
      t.integer :from_deal_id
      t.integer :to_deal_id
      t.references :resource, :polymorphic => true
    end
  end

  def self.down
    drop_table :facts
  end
end
