# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateDeals < ActiveRecord::Migration
  def self.up
    create_table :deals do |t|
      t.string :tag
      t.float :rate
      t.references :entity
      t.references :give, :polymorphic => true
      t.references :take, :polymorphic => true
    end
	add_index :deals, [:entity_id, :tag], :unique => true
  end

  def self.down
    drop_table :deals
  end
end

# vim: ts=2 sts=2 sw=2 et:
