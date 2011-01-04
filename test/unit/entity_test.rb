# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class EntityTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "entity should save" do
    e = Entity.new
    assert !e.save, "Entity without tag saved"
    e.tag = entities(:abstract).tag
    assert !e.save, "Entity with repeating tag saved"
  end
end

# vim: ts=2 sts=2 sw=2 et:
