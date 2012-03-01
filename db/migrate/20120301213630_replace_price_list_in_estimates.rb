# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class ReplacePriceListInEstimates < ActiveRecord::Migration
  def change
    remove_index :estimates, :price_list_id
    rename_column :estimates, :price_list_id, :catalog_id
    add_column :estimates, :date, :datetime
    add_index :estimates, :catalog_id
  end
end
