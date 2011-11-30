# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class SorceryRememberMe < ActiveRecord::Migration
  def change
    add_column :users, :remember_me_token, :string, :default => nil
    add_column :users, :remember_me_token_expires_at, :datetime, :default => nil
    
    add_index :users, :remember_me_token
  end
end
