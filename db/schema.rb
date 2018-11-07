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

ActiveRecord::Schema.define(version: 2018_11_07_093419) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address_line_one"
    t.string "address_line_two"
    t.string "city"
    t.string "county"
    t.string "postcode"
    t.uuid "applicant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_addresses_on_applicant_id"
  end

  create_table "applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name"
    t.string "email_address"
    t.string "national_insurance_number"
  end

  create_table "application_proceeding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "proceeding_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_application_proceeding_types_on_legal_aid_application_id"
    t.index ["proceeding_type_id"], name: "index_application_proceeding_types_on_proceeding_type_id"
  end

  create_table "benefit_check_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.string "result"
    t.string "dwp_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_benefit_check_results_on_legal_aid_application_id"
  end

  create_table "legal_aid_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "application_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "applicant_id"
    t.boolean "has_offline_accounts"
    t.index ["applicant_id"], name: "index_legal_aid_applications_on_applicant_id"
  end

  create_table "proceeding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code"
    t.string "ccms_code"
    t.string "meaning"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ccms_category_law"
    t.string "ccms_category_law_code"
    t.string "ccms_matter"
    t.string "ccms_matter_code"
    t.index ["code"], name: "index_proceeding_types_on_code"
  end

  add_foreign_key "addresses", "applicants"
  add_foreign_key "application_proceeding_types", "legal_aid_applications"
  add_foreign_key "application_proceeding_types", "proceeding_types"
  add_foreign_key "benefit_check_results", "legal_aid_applications"
  add_foreign_key "legal_aid_applications", "applicants"
end
