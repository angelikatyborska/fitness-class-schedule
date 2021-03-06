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

ActiveRecord::Schema.define(version: 20160219102932) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "configurables", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configurables", ["name"], name: "index_configurables_on_name", using: :btree

  create_table "fitness_classes", force: :cascade do |t|
    t.string "name"
    t.text   "description"
    t.string "color"
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "schedule_item_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "status",           default: 0
  end

  add_index "reservations", ["schedule_item_id"], name: "index_reservations_on_schedule_item_id", using: :btree
  add_index "reservations", ["user_id"], name: "index_reservations_on_user_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
  add_index "roles", ["name"], name: "index_roles_on_name", using: :btree

  create_table "room_photos", force: :cascade do |t|
    t.string  "photo"
    t.integer "room_id"
  end

  add_index "room_photos", ["room_id"], name: "index_room_photos_on_room_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "description"
  end

  create_table "schedule_items", force: :cascade do |t|
    t.datetime "start"
    t.integer  "duration"
    t.integer  "capacity"
    t.integer  "trainer_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "room_id"
    t.integer  "fitness_class_id"
    t.integer  "reservations_count", default: 0
  end

  add_index "schedule_items", ["duration"], name: "index_schedule_items_on_duration", using: :btree
  add_index "schedule_items", ["fitness_class_id"], name: "index_schedule_items_on_fitness_class_id", using: :btree
  add_index "schedule_items", ["room_id"], name: "index_schedule_items_on_room_id", using: :btree
  add_index "schedule_items", ["start"], name: "index_schedule_items_on_start", using: :btree
  add_index "schedule_items", ["trainer_id"], name: "index_schedule_items_on_trainer_id", using: :btree

  create_table "site_settings", force: :cascade do |t|
    t.integer  "singleton_guard"
    t.integer  "day_start"
    t.integer  "day_end"
    t.string   "time_zone"
    t.integer  "cancellation_deadline"
    t.string   "site_title"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "site_settings", ["singleton_guard"], name: "index_site_settings_on_singleton_guard", unique: true, using: :btree

  create_table "trainers", force: :cascade do |t|
    t.string   "first_name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "last_name"
    t.string   "photo"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree

  add_foreign_key "reservations", "schedule_items"
  add_foreign_key "reservations", "users"
  add_foreign_key "room_photos", "rooms"
  add_foreign_key "schedule_items", "fitness_classes"
  add_foreign_key "schedule_items", "rooms"
  add_foreign_key "schedule_items", "trainers"
end
