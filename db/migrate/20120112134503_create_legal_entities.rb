# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateLegalEntities < ActiveRecord::Migration
  def change
    create_table :legal_entities do |t|
      t.string :name
      t.references :country
      t.string :identifier_name
      t.string :identifier_value
      t.references :detail, :polymorphic => true
    end
    add_index :legal_entities, :country_id
    add_index :legal_entities, :detail_id
    add_index :legal_entities, [:name, :country_id], :unique => true
  end
end
