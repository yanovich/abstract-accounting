# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class UserMailer < ActionMailer::Base
  default from: "admin@aasii.org"

  def reset_password_email(user)
    @user = user
    @url  = "http://some_url_reset_password/#{user.reset_password_token}"

    mail(:to => user.email, :subject => "Your password has been reset")
  end
end
