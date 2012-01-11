# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateDetailedAssets < ActiveRecord::Migration
  def change
    create_table :detailed_assets do |t|
      t.string :tag
      t.string :brand
      t.references :mu
      t.references :manufacturer
    end
    add_index :detailed_assets, :mu_id
    add_index :detailed_assets, :manufacturer_id
    add_index :detailed_assets, [:tag, :brand, :mu_id], :unique => true
  end
end
