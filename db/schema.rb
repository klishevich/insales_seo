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

ActiveRecord::Schema.define(version: 20160613062420) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_infos", force: :cascade do |t|
    t.integer  "account_id"
    t.integer  "max_products_count"
    t.boolean  "auto_update",          default: false
    t.integer  "seo_field_identifier"
    t.integer  "day_to_update"
    t.boolean  "allow_work",           default: false
    t.date     "last_seo_update"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "account_infos", ["account_id"], name: "index_account_infos_on_account_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.text     "insales_subdomain",                 null: false
    t.text     "password",                          null: false
    t.integer  "insales_id",                        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",             default: false
  end

  add_index "accounts", ["insales_subdomain"], name: "index_accounts_on_insales_subdomain", unique: true, using: :btree

  add_foreign_key "account_infos", "accounts"
end
