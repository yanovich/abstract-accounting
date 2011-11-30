# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.references :entity
      t.string :email
      t.string :crypted_password
      t.string :salt
    end
    add_index :users, [:entity_id, :email], :unique => true
  end
end
