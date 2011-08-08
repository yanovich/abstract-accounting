# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class BalanceSheet < Array
  attr_reader :date, :assets, :liabilities

  def initialize(date = DateTime.now)
    @date = date
    @assets = 0.0
    @liabilities = 0.0
    p = proc do |i|
      self << i
      if i.side == Balance::PASSIVE
        @assets += i.value
      else
        @liabilities += i.value
      end
    end
    Balance.find_all_by_time_frame(date + 1, date).each &p
    Income.find_all_by_time_frame(date + 1, date).each &p
  end
end
