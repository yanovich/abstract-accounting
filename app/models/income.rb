# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Income < ActiveRecord::Base
  PASSIVE = "passive"
  ACTIVE = "active"
  validates :start, :side, :value, :presence => true
  validates :start, :uniqueness => true
  validates :side, :inclusion => { :in => [PASSIVE, ACTIVE] }
  scope :open, where("incomes.paid IS NULL")

  def txn=(txn)
    return nil if txn.nil? or txn.status == 0
    if self.new_record?
      self.start = txn.fact.day
      self.value = txn.earnings
      self.side = PASSIVE
    else
      self.value += txn.earnings
    end
  end
end
