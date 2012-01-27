# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateCatalogsPriceListsJoinTable < ActiveRecord::Migration
  def change
    create_table :catalogs_price_lists, :id => false do |t|
      t.integer :catalog_id
      t.integer :price_list_id
    end
    add_index :catalogs_price_lists, [:catalog_id, :price_list_id], :unique => true
  end
end
