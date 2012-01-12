# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateBusinessPeople < ActiveRecord::Migration
  def change
    create_table :business_people do |t|
      t.references :country
      t.references :identifier, :polymorphic => true
      t.references :person
    end
    add_index :business_people, :country_id
    add_index :business_people, [:identifier_id, :identifier_type]
    add_index :business_people, :person_id
  end
end
