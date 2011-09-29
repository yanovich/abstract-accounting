# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class FactValidator
  def validate(record)
    record.errors[:base] << "bad resource" unless
    (record.resource == record.from.take || record.from.income?) \
    and (record.resource == record.to.give || record.to.income?)
  end
end

class Fact < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :amount
  validates_presence_of :resource_id
  validates_presence_of :from_deal_id
  validates_presence_of :to_deal_id
  validates_with FactValidator
  belongs_to :resource, :polymorphic => true
  belongs_to :from, :class_name => "Deal", :foreign_key => "from_deal_id"
  belongs_to :to, :class_name => "Deal", :foreign_key => "to_deal_id"
  has_one :txn
  before_save :do_save
  before_destroy :do_before_destroy

  scope :pendings, includes("txn").where("txns.id is NULL")

  private
  def do_save
    if changed? or new_record?
      return false unless self.from.update_by_fact(self)
      return false unless self.to.update_by_fact(self)
    end
  end

  def do_before_destroy
    self.amount = -self.amount
    return false unless self.from.update_by_fact(self)
    self.to.update_by_fact(self)
  end
end
