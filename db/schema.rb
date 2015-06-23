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

ActiveRecord::Schema.define(version: 20150609113948) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authorizations", force: :cascade do |t|
    t.string   "provider",    limit: 255
    t.string   "uid",         limit: 255
    t.integer  "customer_id"
    t.string   "token",       limit: 255
    t.string   "secret",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",    limit: 255
  end

  create_table "customers", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",         null: false
    t.string   "encrypted_password",     limit: 255, default: "",         null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,          null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.integer  "failed_attempts",                    default: 0,          null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.string   "company",                limit: 255, default: "",         null: false
    t.string   "first_name",             limit: 255,                      null: false
    t.string   "last_name",              limit: 255,                      null: false
    t.string   "address1",               limit: 255
    t.string   "address2",               limit: 255
    t.string   "city",                   limit: 255
    t.string   "state",                  limit: 255
    t.string   "postal_code",            limit: 10
    t.string   "country",                limit: 255
    t.string   "phone",                  limit: 60
    t.string   "mobile_phone",           limit: 60
    t.string   "role",                   limit: 255, default: "customer", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cms_lang"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "customers", ["confirmation_token"], name: "index_customers_on_confirmation_token", unique: true, using: :btree
  add_index "customers", ["email"], name: "index_customers_on_email", unique: true, using: :btree
  add_index "customers", ["reset_password_token"], name: "index_customers_on_reset_password_token", unique: true, using: :btree
  add_index "customers", ["unlock_token"], name: "index_customers_on_unlock_token", unique: true, using: :btree

  create_table "hardware_locations", force: :cascade do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hardware_id"
  end

  create_table "hardwares", force: :cascade do |t|
    t.string   "identifier",    limit: 255
    t.string   "hardware_type", limit: 255
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "major",         limit: 255
    t.string   "minor",         limit: 255
  end

  create_table "name_translations", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "original_name_id"
    t.string   "lang_code",        limit: 255
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "places", force: :cascade do |t|
    t.integer  "customer_id"
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "latitude"
    t.float    "longitude"
  end

  create_table "purchases", force: :cascade do |t|
    t.integer  "text_record_id"
    t.string   "purchase_id",    limit: 36
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "place_id"
    t.string   "description",       limit: 255
    t.string   "tag_identifier",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
    t.integer  "scan_count"
    t.string   "ancestry",          limit: 255
    t.boolean  "active",                        default: true
    t.time     "active_start_time"
    t.time     "active_stop_time"
    t.boolean  "active_time",                   default: false
    t.boolean  "active_date",                   default: false
    t.date     "active_start_date"
    t.date     "active_stop_date"
  end

  add_index "tags", ["ancestry"], name: "index_tags_on_ancestry", using: :btree

  create_table "text_records", force: :cascade do |t|
    t.integer  "tag_id"
    t.text     "image_uri",              default: "", null: false
    t.text     "link_uri",               default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "gender",     limit: 255
  end

  create_table "translations", force: :cascade do |t|
    t.integer  "text_record_id"
    t.integer  "original_text_id"
    t.string   "lang_code",        limit: 255
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
