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

  def initialize(date)
    @date = date
    @assets_retrieved = false
    @assets = 0.0
    @liabilities = 0.0
  end

  def assets
    retrieve_assets unless @assets_retrieved
    @assets
  end

  def liabilities
    retrieve_assets unless @assets_retrieved
    @liabilities
  end

  def self.all(date = DateTime.now)
    sql = "SELECT id, 'Balance' as type FROM balances
           WHERE balances.start < '#{(date + 1).to_s(:db)}' AND (balances.paid > '#{date.change(:hour => 13).to_s(:db)}' OR balances.paid IS NULL)
           UNION
           SELECT id, 'Income' as type FROM incomes
           WHERE incomes.start < '#{(date + 1).to_s(:db)}' AND (incomes.paid > '#{date.change(:hour => 13).to_s(:db)}' OR incomes.paid IS NULL)"
    bs = BalanceSheet.new(date)
    ActiveRecord::Base.connection.execute(sql).each do |item|
      bs << item["type"].constantize.find(item["id"])
    end
    bs
  end

  protected
  def retrieve_assets
    sql = "SELECT SUM(assets) as assets, SUM(liabilities) as liabilities FROM (
            SELECT id, side, (CASE WHEN side = '#{Balance::ACTIVE}' THEN value ELSE 0.0 END) as assets,
                         (CASE WHEN side = '#{Balance::PASSIVE}' THEN value ELSE 0.0 END) as liabilities FROM balances
            WHERE balances.start < '#{(date + 1).to_s(:db)}' AND (balances.paid > '#{date.change(:hour => 13).to_s(:db)}' OR balances.paid IS NULL)
            UNION
            SELECT id, side, (CASE WHEN side = '#{Balance::ACTIVE}' THEN value ELSE 0.0 END) as assets,
                         (CASE WHEN side = '#{Balance::PASSIVE}' THEN value ELSE 0.0 END) as liabilities FROM incomes
            WHERE incomes.start < '#{(date + 1).to_s(:db)}' AND (incomes.paid > '#{date.change(:hour => 13).to_s(:db)}' OR incomes.paid IS NULL))"
    ActiveRecord::Base.connection.execute(sql).each do |item|
      @assets = item["assets"].to_f
      @liabilities = item["liabilities"].to_f
    end
    @assets_retrieved = true
  end
end
