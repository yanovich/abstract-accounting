# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateBoMElements < ActiveRecord::Migration
  def change
    create_table :bo_m_elements do |t|
      t.references :bom
      t.references :resource
      t.float :rate
    end
    add_index :bo_m_elements, :resource_id
    add_index :bo_m_elements, :bom_id
  end
end
