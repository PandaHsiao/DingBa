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

ActiveRecord::Schema.define(version: 20140218070043) do

  create_table "bookings", force: true do |t|
    t.integer  "user_id"
    t.integer  "restaurant_id"
    t.datetime "booking_time"
    t.string   "res_url",            limit: 30
    t.string   "restaurant_name",    limit: 50
    t.string   "restaurant_address", limit: 180
    t.string   "name",               limit: 20
    t.string   "phone",              limit: 30
    t.string   "email",              limit: 60
    t.string   "remark",             limit: 200
    t.integer  "num_of_people"
    t.string   "participants",       limit: 1000
    t.string   "status",             limit: 1
    t.string   "cancel_note",        limit: 100
    t.string   "feedback",           limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "restaurant_pic"
    t.string   "cancel_key"
  end

  add_index "bookings", ["booking_time"], name: "index_bookings_on_booking_time", using: :btree
  add_index "bookings", ["status"], name: "index_bookings_on_status", using: :btree
  add_index "bookings", ["user_id"], name: "index_bookings_on_user_id", using: :btree

  create_table "day_bookings", force: true do |t|
    t.integer  "restaurant_id"
    t.datetime "day"
    t.integer  "zone1"
    t.integer  "zone2"
    t.integer  "zone3"
    t.integer  "zone4"
    t.integer  "zone5"
    t.integer  "zone6"
    t.integer  "other"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "day_bookings", ["day"], name: "index_day_bookings_on_day", using: :btree
  add_index "day_bookings", ["restaurant_id"], name: "index_day_bookings_on_restaurant_id", using: :btree

  create_table "invite_codes", force: true do |t|
    t.string   "code",       limit: 8
    t.integer  "user_id"
    t.string   "remark",     limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "restaurant_users", force: true do |t|
    t.integer  "restaurant_id"
    t.integer  "user_id"
    t.string   "permission",    limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "restaurant_users", ["restaurant_id"], name: "index_restaurant_users_on_restaurant_id", using: :btree
  add_index "restaurant_users", ["user_id"], name: "index_restaurant_users_on_user_id", using: :btree

  create_table "restaurants", force: true do |t|
    t.string   "res_url",        limit: 30
    t.string   "name",           limit: 50
    t.string   "phone",          limit: 30
    t.string   "city",           limit: 15
    t.string   "area",           limit: 15
    t.string   "address",        limit: 150
    t.string   "res_type",       limit: 2
    t.string   "feature",        limit: 400
    t.string   "business_hours"
    t.string   "pay_type",       limit: 10
    t.string   "supply_person",  limit: 20
    t.string   "supply_email",   limit: 1000
    t.string   "url1",           limit: 500
    t.string   "url2",           limit: 500
    t.string   "url3",           limit: 500
    t.string   "info_url1",      limit: 50
    t.string   "info_url2",      limit: 50
    t.string   "info_url3",      limit: 50
    t.string   "front_cover",    limit: 1
    t.string   "pic_name1",      limit: 50
    t.string   "pic_name2",      limit: 50
    t.string   "pic_name3",      limit: 50
    t.string   "pic_name4",      limit: 50
    t.string   "pic_name5",      limit: 50
    t.integer  "available_hour"
    t.string   "available_date", limit: 5
    t.string   "available_type", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sent_type",      limit: 1
    t.string   "sent_date",      limit: 5
    t.string   "tag"
    t.string   "price_from",     limit: 7
    t.string   "price_to",       limit: 7
    t.string   "home_img",       limit: 50
    t.string   "home_des",       limit: 40
  end

  add_index "restaurants", ["area"], name: "index_restaurants_on_area", using: :btree
  add_index "restaurants", ["business_hours"], name: "index_restaurants_on_business_hours", using: :btree
  add_index "restaurants", ["city"], name: "index_restaurants_on_city", using: :btree
  add_index "restaurants", ["name"], name: "index_restaurants_on_name", using: :btree
  add_index "restaurants", ["pay_type"], name: "index_restaurants_on_pay_type", using: :btree
  add_index "restaurants", ["res_type"], name: "index_restaurants_on_res_type", using: :btree
  add_index "restaurants", ["res_url"], name: "index_restaurants_on_res_url", unique: true, using: :btree
  add_index "restaurants", ["tag"], name: "index_restaurants_on_tag", using: :btree

  create_table "supply_conditions", force: true do |t|
    t.integer  "restaurant_id"
    t.string   "name",           limit: 50
    t.datetime "range_begin"
    t.datetime "range_end"
    t.string   "available_week", limit: 15
    t.integer  "sequence"
    t.string   "status",         limit: 1
    t.string   "is_special",     limit: 1
    t.string   "is_vacation",    limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "supply_conditions", ["range_begin"], name: "index_supply_conditions_on_range_begin", using: :btree
  add_index "supply_conditions", ["range_end"], name: "index_supply_conditions_on_range_end", using: :btree
  add_index "supply_conditions", ["restaurant_id"], name: "index_supply_conditions_on_restaurant_id", using: :btree
  add_index "supply_conditions", ["status"], name: "index_supply_conditions_on_status", using: :btree

  create_table "time_zones", force: true do |t|
    t.integer  "supply_condition_id"
    t.integer  "sequence"
    t.string   "name",                limit: 20
    t.string   "range_begin",         limit: 5
    t.string   "range_end",           limit: 5
    t.integer  "each_allow"
    t.integer  "fifteen_allow"
    t.integer  "total_allow"
    t.string   "status",              limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "time_zones", ["status"], name: "index_time_zones_on_status", using: :btree
  add_index "time_zones", ["supply_condition_id"], name: "index_time_zones_on_supply_condition_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "name",                   limit: 20
    t.string   "role",                   limit: 1
    t.string   "phone",                  limit: 30
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sex"
    t.datetime "birthday"
    t.string   "allow_promot",           limit: 1
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role"], name: "index_users_on_role", using: :btree

end
