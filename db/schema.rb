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

ActiveRecord::Schema.define(:version => 20110104170520) do

  create_table "assets", :force => true do |t|
    t.string "tag"
  end

  add_index "assets", ["tag"], :name => "index_assets_on_tag", :unique => true

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

  create_table "money", :force => true do |t|
    t.integer "num_code"
    t.string  "alpha_code"
  end

  add_index "money", ["alpha_code"], :name => "index_money_on_alpha_code", :unique => true
  add_index "money", ["num_code"], :name => "index_money_on_num_code", :unique => true

end
