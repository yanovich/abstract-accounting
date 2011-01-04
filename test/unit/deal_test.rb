# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class DealTest < ActiveSupport::TestCase
  test "Deal should be stored" do
    d = Deal.new
    assert !d.save, "Empty deal saved"
    d = Deal.new
    d.tag = deals(:equityshare1).tag
    d.rate = deals(:equityshare1).rate
    d.entity = deals(:equityshare1).entity
    assert_raise ActiveRecord::RecordNotUnique do
      !d.save
    end
  end
end

# vim: ts=2 sts=2 sw=2 et:
