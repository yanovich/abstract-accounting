# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require 'spec_helper'

describe User do
  it "should have next behaviour" do
    Factory(:user)
    should validate_presence_of :email
    should validate_presence_of :entity_id
    should validate_uniqueness_of(:email).scoped_to(:entity_id)
    should validate_format_of(:email).not_with("test@test").with_message(/invalid/)
    should ensure_length_of(:password).is_at_least(6)
    should allow_mass_assignment_of(:email)
    should allow_mass_assignment_of(:password)
    should allow_mass_assignment_of(:password_confirmation)
    should allow_mass_assignment_of(:entity)
    should_not allow_mass_assignment_of(:crypted_password)
    should_not allow_mass_assignment_of(:salt)
    should belong_to(:entity)
    should have_many User.versions_association_name
    User.new.root?.should be_false
  end

  it "should authenticate from config" do
    config = YAML::load(File.open("#{Rails.root}/config/application.yml"))
    user = User.authenticate("root@localhost",
                             config["defaults"]["root"]["password"])
    user.should_not be_nil
    user.root?.should be_true
  end

  it "should remember user" do
    user = Factory(:user)
    expect { user.remember_me! }.to change{user.remember_me_token}.from(nil)
    user = Factory(:user)
    expect { user.remember_me! }.to change{user.remember_me_token_expires_at}.from(nil)
  end

  it "should change password" do
    user = Factory(:user)
    new_user = User.load_from_reset_password_token(user.reset_password_token)
    new_user.should eq(user)
    new_user.change_password!("changed")
    new_user.crypted_password.should_not eq(user.crypted_password)
  end
end
