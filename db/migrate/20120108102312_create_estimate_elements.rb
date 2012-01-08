# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class CreateEstimateElements < ActiveRecord::Migration
  def change
    create_table :estimate_elements do |t|
      t.references :estimate
      t.references :bom
      t.float :amount
    end
    add_index :estimate_elements, :estimate_id
    add_index :estimate_elements, :bom_id
  end
end
