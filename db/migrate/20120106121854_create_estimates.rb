# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateEstimates < ActiveRecord::Migration
  def change
    create_table :estimates do |t|
      t.references :entity
      t.references :price_list
      t.references :deal
    end
    add_index :estimates, :entity_id
    add_index :estimates, :price_list_id
    add_index :estimates, :deal_id
  end
end
