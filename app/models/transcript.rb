# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

class Transcript
  attr_reader :deal, :start, :stop

  def initialize(deal, start, stop)
    @deal = deal
    @start = start
    @stop = stop
    @diff_loaded = false
    @opening = nil
    @closing = nil
    @total_debits_diff = 0.0
    @total_credits_diff = 0.0
    @total_loaded = false
  end

  def all()
    deal.txns(start, stop)
  end

  def total_debits
    load_total unless @total_loaded
    @debits
  end

  def total_debits_value
    load_total unless @total_loaded
    @debits_value
  end

  def total_credits
    load_total unless @total_loaded
    @credits
  end

  def total_credits_value
    load_total unless @total_loaded
    @credits_value
  end

  def opening
    load_diffs unless @diff_loaded
    @opening
  end

  def closing
    load_diffs unless @diff_loaded
    @closing
  end

  def total_debits_diff
    load_diffs unless @diff_loaded
    @total_debits_diff
  end

  def total_credits_diff
    load_diffs unless @diff_loaded
    @total_credits_diff
  end

  private
  def load_total
    object = if @deal.income?
      @deal.txns(@start, @stop).
          select("SUM(CASE WHEN txns.earnings > 0.0 THEN txns.earnings ELSE 0.0 END) as credits_value,
                  0.0 as credits,
                  SUM(CASE WHEN txns.earnings < 0.0 THEN -txns.earnings ELSE 0.0 END) as debits_value,
                  0.0 as debits").first
    else
      @deal.txns(@start, @stop).
          select("SUM(CASE WHEN facts.from_deal_id = #{@deal.id} THEN txns.value ELSE 0.0 END) as credits_value,
                  SUM(CASE WHEN facts.from_deal_id = #{@deal.id} THEN facts.amount ELSE 0.0 END) as credits,
                  SUM(CASE WHEN facts.to_deal_id = #{@deal.id} THEN txns.value + txns.earnings ELSE 0.0 END) as debits_value,
                  SUM(CASE WHEN facts.to_deal_id = #{@deal.id} THEN facts.amount ELSE 0.0 END) as debits").first
    end
    @credits_value = object ? object.credits_value : 0.0
    @credits = object ? object.credits : 0.0
    @debits_value = object ? object.debits_value : 0.0
    @debits = object ? object.debits : 0.0
    @total_loaded = true
  end

  def load_diffs
    if @deal.income?
      Income.in_time_frame(@start, @stop)
    else
      @deal.balances.in_time_frame(@start, @stop)
    end.each do |balance|
      if balance.start < @start
        @opening = balance
      else
        @closing = balance if balance.paid.nil? or balance.paid > @stop
        @total_debits_diff += balance.debit_diff
        @total_credits_diff += balance.credit_diff
      end
    end
    @diff_loaded = true
  end
end
