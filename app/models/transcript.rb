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
    @total_debits = 0.0
    @total_debits_value = 0.0
    @total_credits = 0.0
    @total_credits_value = 0.0
    unless @deal.nil?
      load_list
      load_diffs
    end
  end
  attr_reader :deal, :start, :stop, :opening, :closing
  attr_reader :total_debits, :total_debits_value
  attr_reader :total_credits, :total_credits_value

  private
  def load_list
    @deal.txns(@start, @stop).each do |item|
      self << item
      if item.fact.to_deal_id == @deal.id
        @total_debits += item.fact.amount
        @total_debits_value += item.value + item.earnings
      elsif item.fact.from_deal_id == @deal.id
        @total_credits += item.fact.amount
        @total_credits_value += item.value
      end
    end
  end

  def load_diffs
    @deal.balances_by_time_frame(@start, @stop).each do |balance|
      @opening = balance if balance.start < @start
      @closing = balance unless balance.paid.nil?
    end
  end
end
