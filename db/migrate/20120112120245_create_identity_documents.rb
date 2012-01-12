# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateIdentityDocuments < ActiveRecord::Migration
  def change
    create_table :identity_documents do |t|
      t.references :country
      t.string :number
      t.date :date_of_issue
      t.string :authority
      t.references :person
    end
    add_index :identity_documents, :country_id
    add_index :identity_documents, :person_id
    add_index :identity_documents, [:number, :country_id], :unique => true
  end
end
