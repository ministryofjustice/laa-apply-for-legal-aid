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

ActiveRecord::Schema.define(version: 2018_09_17_084624) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applicants", force: :cascade do |t|
    t.string "first_name"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name"
    t.string "email_address"
  end

  create_table "application_proceeding_types", force: :cascade do |t|
    t.bigint "legal_aid_application_id"
    t.bigint "proceeding_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_application_proceeding_types_on_legal_aid_application_id"
    t.index ["proceeding_type_id"], name: "index_application_proceeding_types_on_proceeding_type_id"
  end

  create_table "legal_aid_applications", force: :cascade do |t|
    t.string "application_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "applicant_id"
    t.index ["applicant_id"], name: "index_legal_aid_applications_on_applicant_id"
  end

  create_table "proceeding_types", force: :cascade do |t|
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

end
