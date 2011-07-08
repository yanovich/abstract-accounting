# encoding: UTF-8

# Copyright (C) 2011 Sergey Yanovich <ynvich@gmail.com>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Please see ./COPYING for details

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110707145742) do

  create_table "assets", :force => true do |t|
    t.string "tag"
  end

  add_index "assets", ["tag"], :name => "index_assets_on_tag", :unique => true

  create_table "balances", :force => true do |t|
    t.integer  "deal_id"
    t.string   "side"
    t.float    "amount"
    t.float    "value"
    t.datetime "start"
    t.datetime "paid"
  end

  add_index "balances", ["deal_id", "start"], :name => "index_balances_on_deal_id_and_start", :unique => true

  create_table "charts", :force => true do |t|
    t.integer "currency_id"
  end

  create_table "deals", :force => true do |t|
    t.string  "tag"
    t.float   "rate"
    t.integer "entity_id"
    t.integer "give_id"
    t.string  "give_type"
    t.integer "take_id"
    t.string  "take_type"
  end

  add_index "deals", ["entity_id", "tag"], :name => "index_deals_on_entity_id_and_tag", :unique => true

  create_table "entities", :force => true do |t|
    t.string "tag"
  end

  create_table "facts", :force => true do |t|
    t.datetime "day"
    t.float    "amount"
    t.integer  "from_deal_id"
    t.integer  "to_deal_id"
    t.integer  "resource_id"
    t.string   "resource_type"
  end

  create_table "money", :force => true do |t|
    t.integer "num_code"
    t.string  "alpha_code"
  end

  add_index "money", ["alpha_code"], :name => "index_money_on_alpha_code", :unique => true
  add_index "money", ["num_code"], :name => "index_money_on_num_code", :unique => true

  create_table "states", :force => true do |t|
    t.integer  "deal_id"
    t.string   "side"
    t.float    "amount"
    t.datetime "start"
    t.datetime "paid"
  end

  create_table "txns", :force => true do |t|
    t.integer "fact_id"
    t.float   "value"
    t.integer "status"
    t.float   "earnings"
  end

  add_index "txns", ["fact_id"], :name => "index_txns_on_fact_id", :unique => true

end

# vim: ts=2 sts=2 sw=2 et:
