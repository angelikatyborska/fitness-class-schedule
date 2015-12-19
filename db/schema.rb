# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151218141229) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "schedule_items", force: :cascade do |t|
    t.datetime "start"
    t.integer  "duration"
    t.string   "type"
    t.integer  "capacity"
    t.integer  "trainer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "schedule_items", ["duration"], name: "index_schedule_items_on_duration", using: :btree
  add_index "schedule_items", ["start"], name: "index_schedule_items_on_start", using: :btree
  add_index "schedule_items", ["trainer_id"], name: "index_schedule_items_on_trainer_id", using: :btree

  create_table "trainers", force: :cascade do |t|
    t.string   "first_name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_foreign_key "schedule_items", "trainers"
end
