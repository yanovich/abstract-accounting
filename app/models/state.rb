# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class State < ActiveRecord::Base
  validates :amount, :start, :side, :deal_id, :presence => true
  validates_inclusion_of :side, :in => ["passive", "active"]
  belongs_to :deal

  after_initialize :do_init

  private
  def do_init
    self.side ||= "active"
    self.amount ||= 0.0
  end
end
