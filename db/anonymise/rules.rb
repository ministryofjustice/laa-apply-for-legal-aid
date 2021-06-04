require 'faker'

NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/.freeze

@rules = {
  active_storage_attachments: {},
  active_storage_blobs: {},
  active_storage_variant_records: {},
  actor_permissions: {},
  addresses: {
    address_line_one: -> { Faker::Address.street_address },
    address_line_two: nil,
    city: -> { Faker::Address.city },
    county: -> { Faker::Address.city },
    postcode: -> { Faker::Address.zip },
    organisation: nil
  },
  admin_users: {
    username: -> { Faker::Internet.username },
    email: -> { Faker::Internet.email }
  },
  admin_reports: {
    submitted_applications_report: -> {},
    nonpassported_applications_report: -> {}
  },
  applicants: {
    first_name: -> { Faker::Name.first_name },
    last_name: -> { Faker::Name.last_name },
    email: -> { Faker::Internet.email },
    date_of_birth: -> { Faker::Date.birthday },
    national_insurance_number: -> { Faker::Base.regexify(NINO_REGEXP) }
  },
  application_proceeding_types: {},
  application_proceeding_types_linked_children: {},
  application_proceeding_types_scope_limitations: {},
  attachments: {},
  attempts_to_settles: {
    attempts_made: -> { Faker::Lorem.sentence }
  },
  bank_account_holders: {
    true_layer_response: nil,
    full_name: -> { Faker::Name.name },
    date_of_birth: -> { Faker::Date.birthday },
    addresses: nil
  },
  bank_accounts: {
    name: 'Anonymous bank account',
    true_layer_response: nil,
    account_number: -> { Faker::Bank.account_number },
    sort_code: -> { Faker::Base.regexify(/^[0-9]{2}-[0-9]{2}-[0-9]{2}$/) }
  },
  bank_errors: {
    bank_name: -> { Faker::Bank.name }
  },
  bank_holidays: {},
  bank_providers: {
    true_layer_response: nil,
    bank_name: -> { Faker::Bank.name }
  },
  bank_transactions: {
    description: -> { Faker::Company.industry },
    true_layer_response: nil,
    merchant: -> { Faker::Company.name }
  },
  benefit_check_results: {},
  cash_transactions: {},
  ccms_submission_documents: {},
  ccms_submission_histories: {
    details: nil,
    request: nil,
    response: -> { "\\N\n" }
  },
  ccms_submissions: {},
  cfe_results: {
    result: nil
  },
  cfe_submission_histories: {
    request_payload: nil,
    response_payload: nil
  },
  cfe_submissions: {
    cfe_result: nil
  },
  debugs: {},
  dependants: {
    name: -> { Faker::Name.name }
  },
  dwp_overrides: {},
  feedbacks: {
    improvement_suggestion: -> { Faker::Lorem.paragraph(sentence_count: 2) },
    email: -> { Faker::Internet.email }
  },
  firms: {
    name: -> { "#{Faker::Company.name}\n" }
  },
  gateway_evidences: {},
  incidents: {
    details: -> { Faker::Lorem.sentence }
  },
  involved_children: {
    full_name: -> { Faker::Name.name }
  },
  irregular_incomes: {},
  legal_aid_application_transaction_types: {},
  legal_aid_applications: {},
  malware_scan_results: {
    file_details: {}
    # this is a JSON block that contains the original filename
    # this has the potential to leak the applicant name
    # e.g. jane_smith_statement_of_case.doc, etc
  },
  chances_of_successes: {},
  offices: {
    code: -> { Faker::Base.regexify(/^[0-9][A-Z][0-9]{3}[A-Z]$/) }
  },
  legal_framework_merits_task_lists: {},
  legal_framework_submission_histories: {},
  legal_framework_submissions: {},
  offices_providers: {},
  opponents: {
    full_name: -> { "#{Faker::Name.name}\n" },
    understands_terms_of_court_order_details: -> { Faker::Lorem.sentence },
    warning_letter_sent_details: -> { Faker::Lorem.sentence },
    police_notified_details: -> { Faker::Lorem.sentence },
    bail_conditions_set_details: -> { Faker::Lorem.sentence }
  },
  other_assets_declarations: {},
  permissions: {},
  policy_disregards: {},
  proceeding_type_scope_limitations: {},
  proceeding_types: {},
  providers: {
    username: -> { "#{Faker::Internet.username}_#{Random.rand(1...999).to_s.rjust(3, '0')}" },
    name: -> { Faker::Name.name },
    email: -> { Faker::Internet.email }
  },
  savings_amounts: {},
  scheduled_mailings: {
    # Should we just not export this?
    # The potential PII (email) is embedded in a JSON block
    arguments: -> { {} },
    addressee: -> { Faker::Internet.email }
  },
  statement_of_cases: {
    statement: -> { Faker::Lorem.sentence }
  },
  scope_limitations: {},
  secure_data: {},
  service_levels: {},
  settings: {},
  state_machine_proxies: {},
  transaction_types: {},
  true_layer_banks: {},
  vehicles: {}
}
@rules
