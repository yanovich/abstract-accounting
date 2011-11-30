# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class User < ActiveRecord::Base
  attr_accessible :email, :entity, :password, :password_confirmation
  authenticates_with_sorcery!
  has_paper_trail

  validates :entity_id, :email, :presence => true
  validates_uniqueness_of :email, :scope => :entity_id
  validates :email, :format => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_length_of :password, :minimum => 6, :on => :create
  validates_confirmation_of :password
  belongs_to :entity

  def self.authenticate(email, password, *credentials)
    if "root@localhost" == email &&
       Settings.root.password.to_s == password.to_s
      RootUser.new
    else
      super(email, password, *credentials)
    end
  end

  def root?
    false
  end
end
