# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require "spec_helper"

describe Settings do
  it "contains default user information" do
    config = YAML::load(File.open("#{Rails.root}/config/application.yml"))
    Settings.root.password.should eq(config["defaults"]["root"]["password"])
  end
end
