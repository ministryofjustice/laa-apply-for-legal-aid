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

ActiveRecord::Schema.define(version: 2019_01_02_151638) do

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
    t.string "organisation"
    t.boolean "lookup_used", default: false, null: false
    t.string "lookup_id"
    t.index ["applicant_id"], name: "index_addresses_on_applicant_id"
  end

  create_table "applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "last_name"
    t.string "email"
    t.string "national_insurance_number"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "uses_online_banking"
    t.index ["confirmation_token"], name: "index_applicants_on_confirmation_token", unique: true
    t.index ["email"], name: "index_applicants_on_email"
    t.index ["unlock_token"], name: "index_applicants_on_unlock_token", unique: true
  end

  create_table "application_proceeding_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "proceeding_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_application_proceeding_types_on_legal_aid_application_id"
    t.index ["proceeding_type_id"], name: "index_application_proceeding_types_on_proceeding_type_id"
  end

  create_table "bank_account_holders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_provider_id", null: false
    t.json "true_layer_response"
    t.string "full_name"
    t.json "addresses"
    t.date "date_of_birth"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_provider_id"], name: "index_bank_account_holders_on_bank_provider_id"
  end

  create_table "bank_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_provider_id", null: false
    t.json "true_layer_response"
    t.json "true_layer_balance_response"
    t.string "true_layer_id"
    t.string "name"
    t.string "currency"
    t.string "account_number"
    t.string "sort_code"
    t.decimal "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "account_type"
    t.index ["bank_provider_id"], name: "index_bank_accounts_on_bank_provider_id"
  end

  create_table "bank_errors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "applicant_id", null: false
    t.string "bank_name"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_bank_errors_on_applicant_id"
  end

  create_table "bank_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "applicant_id", null: false
    t.json "true_layer_response"
    t.string "credentials_id"
    t.string "token"
    t.datetime "token_expires_at"
    t.string "name"
    t.string "true_layer_provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_id"], name: "index_bank_providers_on_applicant_id"
  end

  create_table "bank_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "bank_account_id", null: false
    t.json "true_layer_response"
    t.string "true_layer_id"
    t.string "description"
    t.decimal "amount"
    t.string "currency"
    t.string "operation"
    t.string "merchant"
    t.datetime "happened_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id"
  end

  create_table "benefit_check_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.string "result"
    t.string "dwp_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_benefit_check_results_on_legal_aid_application_id"
  end

  create_table "legal_aid_application_restrictions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id"
    t.uuid "restriction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "laa_id_laa_restriction_id"
    t.index ["restriction_id"], name: "index_legal_aid_application_restrictions_on_restriction_id"
  end

  create_table "legal_aid_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "application_ref"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "applicant_id"
    t.boolean "has_offline_accounts"
    t.string "state"
    t.boolean "open_banking_consent"
    t.datetime "open_banking_consent_choice_at"
    t.string "own_home"
    t.decimal "property_value", precision: 10, scale: 2
    t.decimal "percentage_home"
    t.string "shared_ownership"
    t.decimal "outstanding_mortgage_amount"
    t.string "provider_step"
    t.index ["applicant_id"], name: "index_legal_aid_applications_on_applicant_id"
  end

  create_table "other_assets_declarations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.decimal "second_home_value"
    t.decimal "second_home_mortgage"
    t.decimal "second_home_percentage"
    t.decimal "timeshare_value"
    t.decimal "land_value"
    t.decimal "jewellery_value"
    t.decimal "vehicle_value"
    t.decimal "classic_car_value"
    t.decimal "money_assets_value"
    t.decimal "money_owed_value"
    t.decimal "trust_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_other_assets_declarations_on_legal_aid_application_id", unique: true
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

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username", null: false
    t.string "type"
    t.text "roles"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["type"], name: "index_providers_on_type"
    t.index ["username"], name: "index_providers_on_username", unique: true
  end

  create_table "restrictions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "savings_amounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "legal_aid_application_id", null: false
    t.decimal "isa"
    t.decimal "cash"
    t.decimal "other_person_account"
    t.decimal "national_savings"
    t.decimal "plc_shares"
    t.decimal "peps_unit_trusts_capital_bonds_gov_stocks"
    t.decimal "life_assurance_endowment_policy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_savings_amounts_on_legal_aid_application_id"
  end

  create_table "secure_data", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addresses", "applicants"
  add_foreign_key "application_proceeding_types", "legal_aid_applications"
  add_foreign_key "application_proceeding_types", "proceeding_types"
  add_foreign_key "bank_account_holders", "bank_providers"
  add_foreign_key "bank_accounts", "bank_providers"
  add_foreign_key "bank_errors", "applicants"
  add_foreign_key "bank_providers", "applicants"
  add_foreign_key "bank_transactions", "bank_accounts"
  add_foreign_key "benefit_check_results", "legal_aid_applications"
  add_foreign_key "legal_aid_application_restrictions", "legal_aid_applications"
  add_foreign_key "legal_aid_application_restrictions", "restrictions"
  add_foreign_key "legal_aid_applications", "applicants"
  add_foreign_key "savings_amounts", "legal_aid_applications"
end
