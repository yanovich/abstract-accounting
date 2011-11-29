# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require "state_action"

class State < ActiveRecord::Base
  has_paper_trail
  include StateAction

  validates :amount, :start, :side, :deal_id, :presence => true
  validates_inclusion_of :side, :in => [PASSIVE, ACTIVE]
  belongs_to :deal
  after_initialize :do_init
  scope :open, where("states.paid IS NULL")

  private
  def do_init
    self.side ||= ACTIVE if self.attributes.has_key?('side')
    self.amount ||= 0.0 if self.attributes.has_key?('amount')
  end
end
