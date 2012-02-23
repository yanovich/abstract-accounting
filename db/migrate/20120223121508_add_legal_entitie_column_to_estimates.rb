# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class AddLegalEntitieColumnToEstimates < ActiveRecord::Migration
  def change
    remove_column :estimates, :entity_id
    add_column :estimates, :legal_entity_id, :integer
    add_index :estimates, :legal_entity_id
  end
end
