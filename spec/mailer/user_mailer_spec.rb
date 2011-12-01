# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

require "spec_helper"

describe UserMailer do

  describe "password_reset" do
    let(:user) { Factory(:user) }
    let(:mail) { UserMailer.reset_password_email(user) }

    it "send user password reset url" do
      mail.subject.should eq("Your password has been reset")
      mail.to.should eq([user.email])
      mail.from.should eq(["admin@aasii.org"])
      mail.body.encoded.should match(user.reset_password_token)
    end
  end

end
