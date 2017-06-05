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

ActiveRecord::Schema.define(version: 20170604010119) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "street", null: false
    t.string "inner_number", null: false
    t.string "outer_number", null: false
    t.string "neighborhood", null: false
    t.string "postal_code", null: false
    t.string "telephone_1", null: false
    t.string "telephone_2"
    t.string "email", null: false
    t.string "id_name", null: false
    t.integer "trust_level", default: 10, null: false
    t.boolean "active", default: true, null: false
    t.bigint "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_clients_on_creator_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "title", null: false
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.index ["client_id"], name: "index_documents_on_client_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "name", null: false
    t.string "street", null: false
    t.string "inner_number", null: false
    t.string "outer_number", null: false
    t.string "neighborhood", null: false
    t.string "postal_code", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.boolean "active", default: true, null: false
    t.bigint "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_places_on_client_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "email", null: false
    t.string "password_digest"
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.integer "role", null: false
    t.boolean "main", default: false, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "clients", "users", column: "creator_id"
  add_foreign_key "documents", "clients"
  add_foreign_key "places", "clients"
end
