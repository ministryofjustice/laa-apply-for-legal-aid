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

ActiveRecord::Schema[8.1].define(version: 2025_11_20_135805) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.uuid "record_id", null: false
    t.string "record_type", null: false
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "actor_permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "permission_id"
    t.uuid "permittable_id"
    t.string "permittable_type"
    t.datetime "updated_at", null: false
    t.index ["permittable_type", "permittable_id", "permission_id"], name: "actor_permissions_unqiueness", unique: true
    t.index ["permittable_type", "permittable_id"], name: "index_actor_permissions_on_permittable_type_and_permittable_id"
  end

  create_table "addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address_line_one"
    t.string "address_line_three"
    t.string "address_line_two"
    t.uuid "applicant_id", null: false
    t.string "building_number_name"
    t.string "care_of"
    t.string "care_of_first_name"
    t.string "care_of_last_name"
    t.string "care_of_organisation_name"
    t.string "city"
    t.string "country_code"
    t.string "country_name"
    t.string "county"
    t.datetime "created_at", precision: nil, null: false
    t.string "location"
    t.string "lookup_id"
    t.boolean "lookup_used", default: false, null: false
    t.string "organisation"
    t.string "postcode"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["applicant_id"], name: "index_addresses_on_applicant_id"
  end

  create_table "admin_reports", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "admin_users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "auth_provider", default: "", null: false
    t.string "auth_subject_uid"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "username", default: "", null: false
  end

  create_table "allegations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "additional_information"
    t.datetime "created_at", null: false
    t.boolean "denies_all"
    t.uuid "legal_aid_application_id", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_allegations_on_legal_aid_application_id"
  end

  create_table "announcements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "body"
    t.datetime "created_at", null: false
    t.integer "display_type"
    t.datetime "end_at"
    t.string "gov_uk_header_bar"
    t.string "heading"
    t.string "link_display"
    t.string "link_url"
    t.datetime "start_at"
    t.datetime "updated_at", null: false
  end

  create_table "appeals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "court_type"
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id", null: false
    t.string "original_judge_level"
    t.boolean "second_appeal"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_appeals_on_legal_aid_application_id"
  end

  create_table "applicants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "age_for_means_test_purposes"
    t.boolean "applied_previously"
    t.boolean "armed_forces", default: false
    t.boolean "changed_last_name"
    t.datetime "confirmation_sent_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.string "correspondence_address_choice"
    t.datetime "created_at", precision: nil, null: false
    t.date "date_of_birth"
    t.string "email"
    t.boolean "employed"
    t.jsonb "encrypted_true_layer_token"
    t.boolean "extra_employment_information"
    t.string "extra_employment_information_details"
    t.integer "failed_attempts", default: 0, null: false
    t.string "first_name"
    t.boolean "has_national_insurance_number"
    t.boolean "has_partner"
    t.string "last_name"
    t.string "last_name_at_birth"
    t.datetime "locked_at", precision: nil
    t.string "national_insurance_number"
    t.boolean "no_fixed_residence"
    t.boolean "partner_has_contrary_interest"
    t.string "previous_reference"
    t.boolean "receives_state_benefits"
    t.string "relationship_to_children"
    t.datetime "remember_created_at", precision: nil
    t.string "remember_token"
    t.boolean "same_correspondence_and_home_address"
    t.boolean "self_employed", default: false
    t.boolean "shared_benefit_with_partner"
    t.boolean "student_finance"
    t.decimal "student_finance_amount"
    t.string "unlock_token"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["confirmation_token"], name: "index_applicants_on_confirmation_token", unique: true
    t.index ["email"], name: "index_applicants_on_email"
    t.index ["unlock_token"], name: "index_applicants_on_unlock_token", unique: true
  end

  create_table "application_digests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "applicant_age"
    t.boolean "autogranted"
    t.boolean "bank_statements_path"
    t.boolean "biological_parent"
    t.boolean "child_subject"
    t.boolean "contrary_interest"
    t.datetime "created_at", null: false
    t.date "date_started", null: false
    t.date "date_submitted"
    t.integer "days_to_submission"
    t.date "df_reported_date"
    t.boolean "df_used", default: false
    t.date "earliest_df_date"
    t.boolean "ecct_routed"
    t.boolean "employed", default: false, null: false
    t.boolean "family_linked"
    t.string "family_linked_lead_or_associated"
    t.string "firm_name", null: false
    t.boolean "has_partner"
    t.boolean "hmrc_data_used", default: false, null: false
    t.uuid "legal_aid_application_id", null: false
    t.boolean "legal_linked"
    t.string "legal_linked_lead_or_associated"
    t.string "matter_types", null: false
    t.boolean "no_fixed_address"
    t.boolean "non_means_tested"
    t.integer "number_of_family_linked_applications"
    t.integer "number_of_legal_linked_applications"
    t.boolean "parental_responsibility_agreement"
    t.boolean "parental_responsibility_court_order"
    t.boolean "parental_responsibility_evidence"
    t.boolean "partner_dwp_challenge"
    t.boolean "passported", default: false
    t.string "proceedings", null: false
    t.string "provider_username", null: false
    t.boolean "referred_to_caseworker", default: false, null: false
    t.boolean "true_layer_data"
    t.boolean "true_layer_path"
    t.datetime "updated_at", null: false
    t.boolean "use_ccms", default: false
    t.integer "working_days_to_report_df"
    t.integer "working_days_to_submit_df"
    t.index ["legal_aid_application_id"], name: "index_application_digests_on_legal_aid_application_id", unique: true
  end

  create_table "attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "attachment_name"
    t.string "attachment_type"
    t.datetime "created_at", precision: nil, null: false
    t.uuid "legal_aid_application_id"
    t.text "original_filename"
    t.uuid "pdf_attachment_id"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "attempts_to_settles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "attempts_made"
    t.datetime "created_at", null: false
    t.uuid "proceeding_id", null: false
    t.datetime "updated_at", null: false
    t.index ["proceeding_id"], name: "index_attempts_to_settles_on_proceeding_id"
  end

  create_table "bank_account_holders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.json "addresses"
    t.uuid "bank_provider_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.date "date_of_birth"
    t.string "full_name"
    t.json "true_layer_response"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bank_provider_id"], name: "index_bank_account_holders_on_bank_provider_id"
  end

  create_table "bank_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "account_number"
    t.string "account_type"
    t.decimal "balance"
    t.uuid "bank_provider_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "currency"
    t.string "name"
    t.string "sort_code"
    t.json "true_layer_balance_response"
    t.string "true_layer_id"
    t.json "true_layer_response"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bank_provider_id"], name: "index_bank_accounts_on_bank_provider_id"
  end

  create_table "bank_errors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "applicant_id", null: false
    t.string "bank_name"
    t.datetime "created_at", precision: nil, null: false
    t.text "error"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["applicant_id"], name: "index_bank_errors_on_applicant_id"
  end

  create_table "bank_holidays", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "dates"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "bank_providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "applicant_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "credentials_id"
    t.string "name"
    t.string "true_layer_provider_id"
    t.json "true_layer_response"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["applicant_id"], name: "index_bank_providers_on_applicant_id"
    t.index ["true_layer_provider_id", "applicant_id"], name: "index_bank_providers_on_true_layer_provider_id_and_applicant_id", unique: true
  end

  create_table "bank_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount"
    t.uuid "bank_account_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "currency"
    t.string "description"
    t.json "flags"
    t.datetime "happened_at", precision: nil
    t.string "merchant"
    t.string "meta_data"
    t.string "operation"
    t.decimal "running_balance"
    t.uuid "transaction_type_id"
    t.string "true_layer_id"
    t.json "true_layer_response"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["bank_account_id"], name: "index_bank_transactions_on_bank_account_id"
    t.index ["transaction_type_id"], name: "index_bank_transactions_on_transaction_type_id"
  end

  create_table "benefit_check_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "dwp_ref"
    t.uuid "legal_aid_application_id", null: false
    t.string "result"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "index_benefit_check_results_on_legal_aid_application_id"
  end

  create_table "capital_disregards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "account_name"
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.date "date_received"
    t.uuid "legal_aid_application_id", null: false
    t.boolean "mandatory", null: false
    t.string "name", null: false
    t.string "payment_reason"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id", "name", "mandatory"], name: "idx_on_legal_aid_application_id_name_mandatory_f4f47d6261", unique: true
    t.index ["legal_aid_application_id"], name: "index_capital_disregards_on_legal_aid_application_id"
  end

  create_table "cash_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount"
    t.datetime "created_at", null: false
    t.string "legal_aid_application_id"
    t.integer "month_number"
    t.uuid "owner_id"
    t.string "owner_type"
    t.date "transaction_date"
    t.uuid "transaction_type_id"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id", "owner_id", "transaction_type_id", "month_number"], name: "cash_transactions_unique", unique: true
    t.index ["owner_type", "owner_id"], name: "index_cash_transactions_on_owner"
  end

  create_table "ccms_opponent_ids", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "serial_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ccms_submission_documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "attachment_id"
    t.string "ccms_document_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "document_type"
    t.string "status"
    t.uuid "submission_id"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "ccms_submission_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "details"
    t.string "from_state"
    t.text "request"
    t.text "response"
    t.uuid "submission_id", null: false
    t.boolean "success"
    t.string "to_state"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["submission_id"], name: "index_ccms_submission_histories_on_submission_id"
  end

  create_table "ccms_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aasm_state"
    t.string "applicant_add_transaction_id"
    t.string "applicant_ccms_reference"
    t.integer "applicant_poll_count", default: 0
    t.string "case_add_transaction_id"
    t.string "case_ccms_reference"
    t.integer "case_poll_count", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.uuid "legal_aid_application_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "index_ccms_submissions_on_legal_aid_application_id"
  end

  create_table "cfe_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "legal_aid_application_id"
    t.text "result"
    t.uuid "submission_id"
    t.string "type", default: "CFE::V1::Result"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "cfe_submission_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "error_backtrace"
    t.string "error_message"
    t.string "http_method"
    t.integer "http_response_status"
    t.text "request_payload"
    t.text "response_payload"
    t.uuid "submission_id"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
  end

  create_table "cfe_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aasm_state"
    t.uuid "assessment_id"
    t.text "cfe_result"
    t.datetime "created_at", precision: nil, null: false
    t.string "error_message"
    t.uuid "legal_aid_application_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "index_cfe_submissions_on_legal_aid_application_id"
  end

  create_table "chances_of_successes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "application_purpose"
    t.datetime "created_at", precision: nil, null: false
    t.uuid "proceeding_id", null: false
    t.boolean "success_likely"
    t.string "success_prospect"
    t.text "success_prospect_details"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["proceeding_id"], name: "index_chances_of_successes_on_proceeding_id"
  end

  create_table "child_care_assessments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "assessed"
    t.datetime "created_at", null: false
    t.string "details"
    t.uuid "proceeding_id", null: false
    t.boolean "result"
    t.datetime "updated_at", null: false
    t.index ["proceeding_id"], name: "index_child_care_assessments_on_proceeding_id"
  end

  create_table "citizen_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "expires_on", null: false
    t.uuid "legal_aid_application_id", null: false
    t.string "token", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_citizen_access_tokens_on_legal_aid_application_id"
  end

  create_table "debugs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "auth_params"
    t.string "browser_details"
    t.string "callback_params"
    t.string "callback_url"
    t.datetime "created_at", null: false
    t.string "debug_type"
    t.string "error_details"
    t.string "legal_aid_application_id"
    t.text "session"
    t.string "session_id"
    t.datetime "updated_at", null: false
  end

  create_table "dependants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "assets_value"
    t.datetime "created_at", precision: nil, null: false
    t.date "date_of_birth"
    t.boolean "has_assets_more_than_threshold"
    t.boolean "has_income"
    t.boolean "in_full_time_education"
    t.uuid "legal_aid_application_id", null: false
    t.decimal "monthly_income"
    t.string "name"
    t.integer "number"
    t.string "relationship"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "index_dependants_on_legal_aid_application_id"
  end

  create_table "document_categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ccms_document_type"
    t.datetime "created_at", null: false
    t.string "description"
    t.boolean "display_on_evidence_upload", default: false, null: false
    t.string "file_extension"
    t.boolean "mandatory", default: false, null: false
    t.string "name", null: false
    t.boolean "submit_to_ccms", default: false, null: false
    t.datetime "updated_at", null: false
  end

  create_table "domestic_abuse_summaries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "bail_conditions_set"
    t.text "bail_conditions_set_details"
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id", null: false
    t.boolean "police_notified"
    t.text "police_notified_details"
    t.datetime "updated_at", null: false
    t.boolean "warning_letter_sent"
    t.text "warning_letter_sent_details"
    t.index ["legal_aid_application_id"], name: "index_domestic_abuse_summaries_on_legal_aid_application_id"
  end

  create_table "dwp_overrides", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "has_evidence_of_benefit"
    t.uuid "legal_aid_application_id", null: false
    t.text "passporting_benefit"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_dwp_overrides_on_legal_aid_application_id", unique: true
  end

  create_table "employment_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "benefits_in_kind", default: "0.0", null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.uuid "employment_id"
    t.decimal "gross", default: "0.0", null: false
    t.decimal "national_insurance", default: "0.0", null: false
    t.decimal "net_employment_income", default: "0.0", null: false
    t.decimal "tax", default: "0.0", null: false
    t.datetime "updated_at", null: false
    t.index ["employment_id"], name: "index_employment_payments_on_employment_id"
  end

  create_table "employments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id"
    t.string "name", null: false
    t.uuid "owner_id"
    t.string "owner_type"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_employments_on_legal_aid_application_id"
    t.index ["owner_type", "owner_id"], name: "index_employments_on_owner"
  end

  create_table "feedbacks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "browser"
    t.string "browser_version"
    t.string "contact_email"
    t.string "contact_name"
    t.datetime "created_at", precision: nil, null: false
    t.integer "difficulty"
    t.text "difficulty_reason"
    t.boolean "done_all_needed"
    t.text "done_all_needed_reason"
    t.string "email"
    t.text "improvement_suggestion"
    t.uuid "legal_aid_application_id"
    t.string "originating_page"
    t.string "os"
    t.integer "satisfaction"
    t.text "satisfaction_reason"
    t.string "source"
    t.integer "time_taken_satisfaction"
    t.text "time_taken_satisfaction_reason"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "final_hearings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date"
    t.string "details"
    t.boolean "listed", null: false
    t.uuid "proceeding_id", null: false
    t.datetime "updated_at", null: false
    t.integer "work_type"
    t.index ["proceeding_id", "work_type"], name: "proceeding_work_type_unique", unique: true
    t.index ["proceeding_id"], name: "index_final_hearings_on_proceeding_id"
  end

  create_table "firms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ccms_id"
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "hmrc_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id"
    t.uuid "owner_id"
    t.string "owner_type"
    t.json "response"
    t.string "submission_id"
    t.datetime "updated_at", null: false
    t.string "url"
    t.string "use_case"
    t.index ["legal_aid_application_id"], name: "index_hmrc_responses_on_legal_aid_application_id"
    t.index ["owner_type", "owner_id"], name: "index_hmrc_responses_on_owner"
  end

  create_table "incidents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "details"
    t.date "first_contact_date"
    t.uuid "legal_aid_application_id"
    t.date "occurred_on"
    t.date "told_on"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "index_incidents_on_legal_aid_application_id"
  end

  create_table "individuals", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "updated_at", null: false
  end

  create_table "involved_children", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "ccms_opponent_id"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "full_name"
    t.uuid "legal_aid_application_id", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_involved_children_on_legal_aid_application_id"
  end

  create_table "legal_aid_application_transaction_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "legal_aid_application_id"
    t.uuid "owner_id"
    t.string "owner_type"
    t.uuid "transaction_type_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "laa_trans_type_on_legal_aid_application_id"
    t.index ["owner_type", "owner_id"], name: "index_legal_aid_application_transaction_types_on_owner"
    t.index ["transaction_type_id"], name: "laa_trans_type_on_transaction_type_id"
  end

  create_table "legal_aid_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "allowed_document_categories", default: [], null: false, array: true
    t.uuid "applicant_id"
    t.boolean "applicant_in_receipt_of_housing_benefit"
    t.string "application_ref"
    t.boolean "case_cloned"
    t.datetime "client_declaration_confirmed_at", precision: nil
    t.datetime "completed_at", precision: nil
    t.boolean "copy_case"
    t.uuid "copy_case_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "declaration_accepted_at", precision: nil
    t.datetime "discarded_at", precision: nil
    t.boolean "draft"
    t.boolean "dwp_result_confirmed"
    t.boolean "emergency_cost_override"
    t.string "emergency_cost_reasons"
    t.decimal "emergency_cost_requested"
    t.boolean "extra_employment_information"
    t.string "extra_employment_information_details"
    t.string "full_employment_details"
    t.boolean "has_dependants"
    t.boolean "has_offline_accounts"
    t.boolean "has_restrictions"
    t.boolean "in_scope_of_laspo"
    t.boolean "linked_application_completed"
    t.datetime "merits_submitted_at", precision: nil
    t.boolean "no_cash_income"
    t.boolean "no_cash_outgoings"
    t.boolean "no_credit_transaction_types_selected"
    t.boolean "no_debit_transaction_types_selected"
    t.uuid "office_id"
    t.boolean "open_banking_consent"
    t.datetime "open_banking_consent_choice_at", precision: nil
    t.decimal "outstanding_mortgage_amount"
    t.string "own_home"
    t.boolean "own_vehicle"
    t.decimal "percentage_home"
    t.boolean "plf_court_order"
    t.decimal "property_value", precision: 10, scale: 2
    t.uuid "provider_id"
    t.boolean "provider_received_citizen_consent"
    t.string "provider_step"
    t.json "provider_step_params"
    t.date "purgeable_on"
    t.string "restrictions_details"
    t.text "reviewed"
    t.boolean "separate_representation_required"
    t.string "shared_ownership"
    t.boolean "substantive_application"
    t.date "substantive_application_deadline_on"
    t.boolean "substantive_cost_override"
    t.string "substantive_cost_reasons"
    t.decimal "substantive_cost_requested"
    t.date "transaction_period_finish_on"
    t.date "transaction_period_start_on"
    t.boolean "transactions_gathered"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["applicant_id"], name: "index_legal_aid_applications_on_applicant_id"
    t.index ["application_ref"], name: "index_legal_aid_applications_on_application_ref", unique: true
    t.index ["discarded_at"], name: "index_legal_aid_applications_on_discarded_at"
    t.index ["office_id"], name: "index_legal_aid_applications_on_office_id"
    t.index ["provider_id"], name: "index_legal_aid_applications_on_provider_id"
  end

  create_table "legal_framework_merits_task_lists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id"
    t.text "serialized_data"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "idx_lfa_merits_task_lists_on_legal_aid_application_id"
  end

  create_table "legal_framework_submission_histories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_backtrace"
    t.string "error_message"
    t.string "http_method"
    t.integer "http_response_status"
    t.text "request_payload"
    t.text "response_payload"
    t.uuid "submission_id"
    t.datetime "updated_at", null: false
    t.string "url"
  end

  create_table "legal_framework_submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "error_message"
    t.uuid "legal_aid_application_id"
    t.uuid "request_id"
    t.text "result"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_legal_framework_submissions_on_legal_aid_application_id"
  end

  create_table "linked_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "associated_application_id", null: false
    t.boolean "confirm_link"
    t.datetime "created_at", null: false
    t.uuid "lead_application_id"
    t.string "link_type_code"
    t.uuid "target_application_id"
    t.datetime "updated_at", null: false
    t.index ["associated_application_id"], name: "index_linked_applications_on_associated_application_id"
    t.index ["lead_application_id", "associated_application_id"], name: "index_linked_applications", unique: true
    t.index ["lead_application_id"], name: "index_linked_applications_on_lead_application_id"
    t.index ["target_application_id"], name: "index_linked_applications_on_target_application_id"
  end

  create_table "malware_scan_results", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.json "file_details"
    t.text "scan_result"
    t.boolean "scanner_working"
    t.datetime "updated_at", precision: nil, null: false
    t.uuid "uploader_id"
    t.string "uploader_type"
    t.boolean "virus_found", null: false
    t.index ["uploader_type", "uploader_id"], name: "index_malware_scan_results_on_uploader_type_and_uploader_id"
  end

  create_table "matter_oppositions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id", null: false
    t.boolean "matter_opposed"
    t.text "reason", default: "", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_matter_oppositions_on_legal_aid_application_id"
  end

  create_table "offices", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address_line_four"
    t.string "address_line_one"
    t.string "address_line_three"
    t.string "address_line_two"
    t.string "ccms_id"
    t.string "city"
    t.string "code"
    t.string "county"
    t.datetime "created_at", precision: nil, null: false
    t.uuid "firm_id"
    t.string "postcode"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["firm_id"], name: "index_offices_on_firm_id"
  end

  create_table "offices_providers", id: false, force: :cascade do |t|
    t.uuid "office_id", null: false
    t.uuid "provider_id", null: false
    t.index ["office_id"], name: "index_offices_providers_on_office_id"
    t.index ["provider_id"], name: "index_offices_providers_on_provider_id"
  end

  create_table "opponents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "ccms_opponent_id"
    t.datetime "created_at", precision: nil, null: false
    t.boolean "exists_in_ccms", default: false
    t.uuid "legal_aid_application_id", null: false
    t.uuid "opposable_id"
    t.string "opposable_type"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "index_opponents_on_legal_aid_application_id"
    t.index ["opposable_type", "opposable_id"], name: "index_opponents_on_opposable", unique: true
  end

  create_table "opponents_applications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "has_opponents_application"
    t.uuid "proceeding_id", null: false
    t.string "reason_for_applying"
    t.datetime "updated_at", null: false
    t.index ["proceeding_id"], name: "index_opponents_applications_on_proceeding_id"
  end

  create_table "organisations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "ccms_type_code", null: false
    t.string "ccms_type_text", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "other_assets_declarations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.decimal "inherited_assets_value"
    t.decimal "land_value"
    t.uuid "legal_aid_application_id", null: false
    t.decimal "money_owed_value"
    t.boolean "none_selected"
    t.decimal "second_home_mortgage"
    t.decimal "second_home_percentage"
    t.decimal "second_home_value"
    t.decimal "timeshare_property_value"
    t.decimal "trust_value"
    t.datetime "updated_at", precision: nil, null: false
    t.decimal "valuable_items_value"
    t.index ["legal_aid_application_id"], name: "index_other_assets_declarations_on_legal_aid_application_id", unique: true
  end

  create_table "parties_mental_capacities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id", null: false
    t.boolean "understands_terms_of_court_order"
    t.text "understands_terms_of_court_order_details"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_parties_mental_capacities_on_legal_aid_application_id"
  end

  create_table "partners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "armed_forces"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.boolean "employed"
    t.boolean "extra_employment_information"
    t.string "extra_employment_information_details"
    t.string "first_name"
    t.string "full_employment_details"
    t.boolean "has_national_insurance_number"
    t.string "last_name"
    t.uuid "legal_aid_application_id", null: false
    t.string "national_insurance_number"
    t.boolean "no_cash_income"
    t.boolean "no_cash_outgoings"
    t.boolean "receives_state_benefits"
    t.boolean "self_employed"
    t.boolean "shared_benefit_with_applicant"
    t.boolean "student_finance"
    t.decimal "student_finance_amount"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_partners_on_legal_aid_application_id"
  end

  create_table "permissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "description"
    t.string "role"
    t.index ["role"], name: "index_permissions_on_role", unique: true
  end

  create_table "policy_disregards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "criminal_injuries_compensation_scheme"
    t.boolean "england_infected_blood_support"
    t.uuid "legal_aid_application_id"
    t.boolean "london_emergencies_trust"
    t.boolean "national_emergencies_trust"
    t.boolean "none_selected"
    t.datetime "updated_at", null: false
    t.boolean "vaccine_damage_payments"
    t.boolean "variant_creutzfeldt_jakob_disease"
    t.boolean "we_love_manchester_emergency_fund"
    t.index ["legal_aid_application_id"], name: "index_policy_disregards_on_legal_aid_application_id"
  end

  create_table "proceedings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "accepted_emergency_defaults"
    t.boolean "accepted_substantive_defaults"
    t.string "category_law_code", null: false
    t.string "category_of_law", null: false
    t.string "ccms_code", null: false
    t.string "ccms_matter_code"
    t.string "client_involvement_type_ccms_code"
    t.string "client_involvement_type_description"
    t.datetime "created_at", null: false
    t.decimal "delegated_functions_cost_limitation", null: false
    t.string "description", null: false
    t.integer "emergency_level_of_service"
    t.string "emergency_level_of_service_name"
    t.integer "emergency_level_of_service_stage"
    t.boolean "lead_proceeding", default: false, null: false
    t.uuid "legal_aid_application_id", null: false
    t.string "matter_type", null: false
    t.string "meaning", null: false
    t.string "name", null: false
    t.integer "proceeding_case_id"
    t.string "related_orders", default: [], null: false, array: true
    t.string "sca_type"
    t.decimal "substantive_cost_limitation", null: false
    t.integer "substantive_level_of_service"
    t.string "substantive_level_of_service_name"
    t.integer "substantive_level_of_service_stage"
    t.datetime "updated_at", null: false
    t.boolean "used_delegated_functions"
    t.date "used_delegated_functions_on"
    t.date "used_delegated_functions_reported_on"
    t.index ["legal_aid_application_id"], name: "index_proceedings_on_legal_aid_application_id"
    t.index ["proceeding_case_id"], name: "index_proceedings_on_proceeding_case_id", unique: true
  end

  create_table "proceedings_linked_children", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "involved_child_id"
    t.uuid "proceeding_id"
    t.datetime "updated_at", null: false
    t.index ["involved_child_id", "proceeding_id"], name: "index_involved_child_proceeding", unique: true
    t.index ["proceeding_id", "involved_child_id"], name: "index_proceeding_involved_child", unique: true
  end

  create_table "prohibited_steps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "details"
    t.uuid "proceeding_id", null: false
    t.boolean "uk_removal"
    t.datetime "updated_at", null: false
    t.index ["proceeding_id"], name: "index_prohibited_steps_on_proceeding_id"
  end

  create_table "provider_dismissed_announcements", id: false, force: :cascade do |t|
    t.uuid "announcement_id", null: false
    t.uuid "provider_id", null: false
    t.index ["provider_id", "announcement_id"], name: "idx_on_provider_id_announcement_id_d796f4e801"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "auth_provider", default: "", null: false
    t.string "auth_subject_uid"
    t.integer "ccms_contact_id"
    t.boolean "cookies_enabled"
    t.datetime "cookies_saved_at"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.inet "current_sign_in_ip"
    t.string "email"
    t.uuid "firm_id"
    t.datetime "last_sign_in_at", precision: nil
    t.inet "last_sign_in_ip"
    t.string "name"
    t.text "office_codes"
    t.text "roles"
    t.uuid "selected_office_id"
    t.integer "sign_in_count", default: 0, null: false
    t.string "silas_id"
    t.string "type"
    t.datetime "updated_at", precision: nil, null: false
    t.string "username"
    t.index ["auth_subject_uid", "auth_provider"], name: "index_providers_on_auth_subject_uid_and_auth_provider", unique: true
    t.index ["firm_id"], name: "index_providers_on_firm_id"
    t.index ["selected_office_id"], name: "index_providers_on_selected_office_id"
    t.index ["type"], name: "index_providers_on_type"
    t.index ["username"], name: "index_providers_on_username", unique: true
  end

  create_table "regular_transactions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "amount", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.string "frequency", null: false
    t.uuid "legal_aid_application_id", null: false
    t.uuid "owner_id"
    t.string "owner_type"
    t.uuid "transaction_type_id", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_regular_transactions_on_legal_aid_application_id"
    t.index ["owner_type", "owner_id"], name: "index_regular_transactions_on_owner"
    t.index ["transaction_type_id"], name: "index_regular_transactions_on_transaction_type_id"
  end

  create_table "savings_amounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "cash"
    t.datetime "created_at", precision: nil, null: false
    t.decimal "joint_offline_current_accounts"
    t.decimal "joint_offline_savings_accounts"
    t.uuid "legal_aid_application_id", null: false
    t.decimal "life_assurance_endowment_policy"
    t.decimal "national_savings"
    t.boolean "no_account_selected"
    t.boolean "no_partner_account_selected"
    t.boolean "none_selected"
    t.decimal "offline_current_accounts"
    t.decimal "offline_savings_accounts"
    t.decimal "other_person_account"
    t.decimal "partner_offline_current_accounts"
    t.decimal "partner_offline_savings_accounts"
    t.decimal "peps_unit_trusts_capital_bonds_gov_stocks"
    t.decimal "plc_shares"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["legal_aid_application_id"], name: "index_savings_amounts_on_legal_aid_application_id"
  end

  create_table "scheduled_mailings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "addressee"
    t.string "arguments", null: false
    t.datetime "cancelled_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "govuk_message_id"
    t.uuid "legal_aid_application_id"
    t.string "mailer_klass", null: false
    t.string "mailer_method", null: false
    t.datetime "scheduled_at", precision: nil, null: false
    t.datetime "sent_at", precision: nil
    t.string "status"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "schedules", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "area_of_law"
    t.string "authorisation_status"
    t.boolean "cancelled"
    t.string "category_of_law"
    t.datetime "created_at", null: false
    t.string "devolved_power_status"
    t.date "end_date"
    t.integer "license_indicator"
    t.uuid "office_id", null: false
    t.date "start_date"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["office_id"], name: "index_schedules_on_office_id"
  end

  create_table "scope_limitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.date "hearing_date"
    t.string "limitation_note"
    t.string "meaning", null: false
    t.uuid "proceeding_id", null: false
    t.integer "scope_type"
    t.datetime "updated_at", null: false
    t.index ["proceeding_id"], name: "index_scope_limitations_on_proceeding_id"
  end

  create_table "settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "alert_via_sentry", default: true, null: false
    t.boolean "allow_welsh_translation", default: false, null: false
    t.string "bank_transaction_filename", default: "db/sample_data/bank_transactions.csv"
    t.datetime "cfe_compare_run_at"
    t.boolean "collect_dwp_data", default: true, null: false
    t.boolean "collect_hmrc_data", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "digest_extracted_at", precision: nil, default: "1970-01-01 00:00:01"
    t.boolean "enable_ccms_submission", default: true, null: false
    t.boolean "enable_datastore_submission", default: false, null: false
    t.boolean "manually_review_all_cases", default: true
    t.boolean "mock_true_layer_data", default: false, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "specific_issues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "details"
    t.uuid "proceeding_id", null: false
    t.datetime "updated_at", null: false
    t.index ["proceeding_id"], name: "index_specific_issues_on_proceeding_id"
  end

  create_table "state_machine_proxies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "aasm_state"
    t.string "ccms_reason"
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id"
    t.string "type"
    t.datetime "updated_at", null: false
  end

  create_table "statement_of_cases", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.uuid "legal_aid_application_id", null: false
    t.uuid "provider_uploader_id"
    t.text "statement"
    t.boolean "typed"
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "upload"
    t.index ["legal_aid_application_id"], name: "index_statement_of_cases_on_legal_aid_application_id"
    t.index ["provider_uploader_id"], name: "index_statement_of_cases_on_provider_uploader_id"
  end

  create_table "temp_contract_data", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "office_code"
    t.json "response"
    t.boolean "success"
    t.datetime "updated_at", null: false
  end

  create_table "transaction_types", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "archived_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.string "operation"
    t.boolean "other_income", default: false
    t.string "parent_id"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["parent_id"], name: "index_transaction_types_on_parent_id"
  end

  create_table "true_layer_banks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "banks"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "undertakings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "additional_information"
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id", null: false
    t.boolean "offered"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_undertakings_on_legal_aid_application_id"
  end

  create_table "uploaded_evidence_collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "legal_aid_application_id", null: false
    t.uuid "provider_uploader_id"
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_uploaded_evidence_collections_on_legal_aid_application_id"
    t.index ["provider_uploader_id"], name: "index_uploaded_evidence_collections_on_provider_uploader_id"
  end

  create_table "urgencies", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "additional_information"
    t.datetime "created_at", null: false
    t.date "hearing_date"
    t.boolean "hearing_date_set"
    t.uuid "legal_aid_application_id", null: false
    t.string "nature_of_urgency", null: false
    t.datetime "updated_at", null: false
    t.index ["legal_aid_application_id"], name: "index_urgencies_on_legal_aid_application_id"
  end

  create_table "vary_orders", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "details"
    t.uuid "proceeding_id", null: false
    t.datetime "updated_at", null: false
    t.index ["proceeding_id"], name: "index_vary_orders_on_proceeding_id"
  end

  create_table "vehicles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.decimal "estimated_value"
    t.uuid "legal_aid_application_id"
    t.boolean "more_than_three_years_old"
    t.string "owner"
    t.decimal "payment_remaining"
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "used_regularly"
    t.index ["legal_aid_application_id"], name: "index_vehicles_on_legal_aid_application_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "applicants"
  add_foreign_key "allegations", "legal_aid_applications"
  add_foreign_key "appeals", "legal_aid_applications"
  add_foreign_key "attempts_to_settles", "proceedings"
  add_foreign_key "bank_account_holders", "bank_providers"
  add_foreign_key "bank_accounts", "bank_providers"
  add_foreign_key "bank_errors", "applicants"
  add_foreign_key "bank_providers", "applicants"
  add_foreign_key "bank_transactions", "bank_accounts"
  add_foreign_key "benefit_check_results", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "capital_disregards", "legal_aid_applications"
  add_foreign_key "ccms_submission_documents", "ccms_submissions", column: "submission_id"
  add_foreign_key "ccms_submission_histories", "ccms_submissions", column: "submission_id"
  add_foreign_key "ccms_submissions", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "cfe_submissions", "legal_aid_applications"
  add_foreign_key "chances_of_successes", "proceedings", on_delete: :cascade
  add_foreign_key "child_care_assessments", "proceedings"
  add_foreign_key "citizen_access_tokens", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "dependants", "legal_aid_applications"
  add_foreign_key "domestic_abuse_summaries", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "dwp_overrides", "legal_aid_applications"
  add_foreign_key "employment_payments", "employments"
  add_foreign_key "employments", "legal_aid_applications"
  add_foreign_key "final_hearings", "proceedings"
  add_foreign_key "hmrc_responses", "legal_aid_applications"
  add_foreign_key "involved_children", "legal_aid_applications"
  add_foreign_key "legal_aid_applications", "applicants"
  add_foreign_key "legal_aid_applications", "offices"
  add_foreign_key "legal_aid_applications", "providers"
  add_foreign_key "legal_framework_merits_task_lists", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "legal_framework_submissions", "legal_aid_applications"
  add_foreign_key "linked_applications", "legal_aid_applications", column: "associated_application_id"
  add_foreign_key "linked_applications", "legal_aid_applications", column: "lead_application_id"
  add_foreign_key "matter_oppositions", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "offices", "firms"
  add_foreign_key "offices_providers", "offices"
  add_foreign_key "offices_providers", "providers"
  add_foreign_key "opponents", "legal_aid_applications"
  add_foreign_key "opponents_applications", "proceedings"
  add_foreign_key "parties_mental_capacities", "legal_aid_applications"
  add_foreign_key "partners", "legal_aid_applications"
  add_foreign_key "policy_disregards", "legal_aid_applications"
  add_foreign_key "proceedings", "legal_aid_applications"
  add_foreign_key "prohibited_steps", "proceedings"
  add_foreign_key "providers", "firms"
  add_foreign_key "providers", "offices", column: "selected_office_id"
  add_foreign_key "regular_transactions", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "regular_transactions", "transaction_types"
  add_foreign_key "savings_amounts", "legal_aid_applications"
  add_foreign_key "scheduled_mailings", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "schedules", "offices"
  add_foreign_key "scope_limitations", "proceedings"
  add_foreign_key "specific_issues", "proceedings"
  add_foreign_key "statement_of_cases", "legal_aid_applications", on_delete: :cascade
  add_foreign_key "statement_of_cases", "providers", column: "provider_uploader_id"
  add_foreign_key "undertakings", "legal_aid_applications"
  add_foreign_key "uploaded_evidence_collections", "legal_aid_applications"
  add_foreign_key "urgencies", "legal_aid_applications"
  add_foreign_key "vary_orders", "proceedings"
  add_foreign_key "vehicles", "legal_aid_applications"
end
