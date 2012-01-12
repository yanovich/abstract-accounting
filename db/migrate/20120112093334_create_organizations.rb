# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :full_name
      t.string :short_name
      t.references :country
      t.string :address
      t.references :identifier, :polymorphic => true
    end
    add_index :organizations, :country_id
    add_index :organizations, [:identifier_id, :identifier_type]
  end
end
