# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateResources < ActiveRecord::Migration
  def self.up
	create_table :assets do |t|
		t.string :tag
	end
	create_table :money do |t|
		t.integer :num_code
		t.string :alpha_code
	end
	add_index :money, :num_code, :unique => true
	add_index :money, :alpha_code, :unique => true
	add_index :assets, :tag, :unique => true
  end

  def self.down
	drop_table :assets
	drop_table :money
  end
end

# vim: ts=2 sts=2 sw=2 et:
