# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class BalanceSheet < Array
  attr_reader :date

  def initialize(date = DateTime.now)
    @date = date
    Balance.find_all_by_time_frame(date, date).each { |b| self << b }
    Income.find_all_by_time_frame(date, date).each { |i| self << i }
  end
end
