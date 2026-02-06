# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_02_06_171209) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "feelings", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "impressions", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "message_impressions", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "impression_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["impression_id"], name: "index_message_impressions_on_impression_id"
    t.index ["message_id", "impression_id"], name: "index_message_impressions_on_message_id_and_impression_id", unique: true
    t.index ["message_id"], name: "index_message_impressions_on_message_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "recipient_id", null: false
    t.bigint "occasion_id", null: false
    t.bigint "feeling_id", null: false
    t.text "episode"
    t.text "additional_message"
    t.text "generated_content"
    t.text "edited_content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feeling_id"], name: "index_messages_on_feeling_id"
    t.index ["occasion_id"], name: "index_messages_on_occasion_id"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
  end

  create_table "occasions", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipients", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "message_impressions", "impressions"
  add_foreign_key "message_impressions", "messages"
  add_foreign_key "messages", "feelings"
  add_foreign_key "messages", "occasions"
  add_foreign_key "messages", "recipients"
end
