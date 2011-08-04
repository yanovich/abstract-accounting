# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Transcript < Array
  def initialize(deal, start, stop)
    @deal = deal
    @start = start
    @stop = stop
    unless @deal.nil?
      load_list
      load_diffs
    end
  end
  attr_reader :deal, :start, :stop, :opening, :closing

  private
  def load_list
    @deal.txns(@start, @stop).each do |item|
      self << item
    end
  end

  def load_diffs
    @deal.balances_by_time_frame(@start, @stop).each do |balance|
      @opening = balance if balance.paid.nil?
      @closing = balance unless balance.paid.nil?
    end
  end
end
