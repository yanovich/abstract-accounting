# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "asset should store" do
    a = Asset.new
    assert !a.save, "Asset with empty tag saved"
    a.tag = assets(:aasiishare).tag
    assert !a.save, "Asset with repeating tag saved"
  end

  test "money should store" do
    m = Money.new
    m.num_code = 840
    m.alpha_code = money(:rub).alpha_code
    assert !m.save, "Money with repeating tag saved"
    m = Money.new
    assert !m.save, "Money with empty num_code and alpha_code saved"
    m.num_code = 643
    assert !m.save, "Money with empty alpha_code saved"
    m.alpha_code = "RUB"
    assert !m.save, "Copy of rub money is saved"
  end
end

# vim: ts=2 sts=2 sw=2 et:
