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

ActiveRecord::Schema[8.0].define(version: 2025_08_08_053926) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "conversions", force: :cascade do |t|
    t.decimal "amount", precision: 18, scale: 6, null: false
    t.string "base_currency", limit: 3, null: false
    t.string "target_currency", limit: 3, null: false
    t.decimal "rate_used", precision: 18, scale: 10, null: false
    t.decimal "converted_amount", precision: 18, scale: 6, null: false
    t.datetime "rate_fetched_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_currency", "target_currency", "rate_fetched_at"], name: "idx_on_base_currency_target_currency_rate_fetched_a_b7671bd9e8"
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.string "base_currency", limit: 3, null: false
    t.string "target_currency", limit: 3, null: false
    t.decimal "rate", precision: 18, scale: 10, null: false
    t.datetime "fetched_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["base_currency", "target_currency"], name: "index_exchange_rates_on_base_currency_and_target_currency", unique: true
  end
end
