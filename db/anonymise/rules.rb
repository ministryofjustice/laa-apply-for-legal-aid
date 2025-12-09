require "faker"

# If you see a "extra data after last expected column" when attempting to restore
# it means that the final column in the table has been anonymized and it removes
# the newline.  If this occurs on a new table, change the final column in the
# table, check the output, and add a new line character after your new, anonymized,
# data, e.g. ```last_name: -> { "#{Faker::Name.last_name}\n" },```

NINO_REGEXP = /^[A-CEGHJ-PR-TW-Z]{1}[A-CEGHJ-NPR-TW-Z]{1}[0-9]{6}[A-DFM]{1}$/

@rules = {
  temp_contract_data: {},
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
    building_number_name: -> { Faker::Address.building_number },
    organisation: nil,
  },
  admin_users: {
    username: -> { Faker::Internet.username },
    email: -> { Faker::Internet.email },
  },
  admin_reports: {
    submitted_applications_report: -> {},
    nonpassported_applications_report: -> {},
  },
  allegations: {
    additional_information: -> { Faker::Lorem.sentence },
  },
  announcements: {},
  appeals: {},
  applicants: {
    first_name: -> { Faker::Name.first_name },
    last_name: -> { Faker::Name.last_name },
    email: -> { Faker::Internet.email },
    date_of_birth: -> { Faker::Date.birthday },
    national_insurance_number: -> { Faker::Base.regexify(NINO_REGEXP) },
  },
  application_digests: {},
  attachments: {
    original_filename: -> { "#{Faker::Bank.name}.pdf\n" },
  },
  attempts_to_settles: {
    attempts_made: -> { Faker::Lorem.sentence },
  },
  bank_account_holders: {
    true_layer_response: nil,
    full_name: -> { Faker::Name.name },
    date_of_birth: -> { Faker::Date.birthday },
    addresses: nil,
  },
  bank_accounts: {
    name: "Anonymous bank account",
    true_layer_response: nil,
    account_number: -> { Faker::Bank.account_number },
    sort_code: -> { Faker::Base.regexify(/^[0-9]{2}-[0-9]{2}-[0-9]{2}$/) },
  },
  bank_errors: {
    bank_name: -> { Faker::Bank.name },
  },
  bank_holidays: {},
  bank_providers: {
    true_layer_response: nil,
    bank_name: -> { Faker::Bank.name },
  },
  bank_transactions: {
    description: -> { Faker::Company.industry },
    true_layer_response: nil,
    merchant: -> { Faker::Company.name },
  },
  benefit_check_results: {},
  capital_disregards: {},
  cash_transactions: {},
  ccms_submission_documents: {},
  ccms_submission_histories: {
    details: nil,
    request: nil,
    response: -> { "\\N\n" },
  },
  ccms_opponent_ids: {},
  ccms_submissions: {},
  cfe_results: {
    result: nil,
  },
  cfe_submission_histories: {
    request_payload: nil,
    response_payload: nil,
  },
  cfe_submissions: {
    cfe_result: nil,
  },
  chances_of_successes: {
    success_prospect_details: lambda do |original_value, row_context|
      row_context[:field_1_val] = Faker::Lorem.paragraph(sentence_count: 2) unless original_value.eql?('\N')
    end,
  },
  child_care_assessments: {
    details: lambda do |original_value, row_context|
      row_context[:field_1_val] = Faker::Lorem.paragraph(sentence_count: 2) unless original_value.eql?('\N')
    end,
  },
  citizen_access_tokens: {},
  datastore_submissions: {
    body: -> { "" },
    headers: -> { { "location" => "https://fake-api-domain-for-data-access-api/api/v0/applications/#{Faker::Internet.uuid}" } },
  },
  debugs: {},
  dependants: {
    name: -> { Faker::Name.name },
  },
  document_categories: {},
  domestic_abuse_summaries: {
    warning_letter_sent_details: Faker::Lorem.paragraph(sentence_count: 2),
    police_notified_details: Faker::Lorem.paragraph(sentence_count: 2),
    bail_conditions_set_details: Faker::Lorem.paragraph(sentence_count: 2),
  },
  dwp_overrides: {},
  employments: {},
  employment_payments: {},
  feedbacks: {
    done_all_needed_reason: -> { Faker::Lorem.paragraph(sentence_count: 2) },
    difficulty_reason: -> { Faker::Lorem.paragraph(sentence_count: 2) },
    satisfaction_reason: -> { Faker::Lorem.paragraph(sentence_count: 2) },
    time_taken_satisfaction_reason: -> { Faker::Lorem.paragraph(sentence_count: 2) },
    improvement_suggestion: -> { Faker::Lorem.paragraph(sentence_count: 2) },
    email: -> { Faker::Internet.email },
    contact_email: -> { Faker::Internet.email },
    contact_name: -> { Faker::Name.name },
  },
  final_hearings: {},
  firms: {
    name: -> { "#{Faker::Company.name}\n" },
  },
  hmrc_responses: {
    response: nil,
  },
  incidents: {
    details: -> { Faker::Lorem.sentence },
  },
  individuals: {
    first_name: -> { Faker::Name.first_name },
    last_name: -> { Faker::Name.last_name },
  },
  involved_children: {
    full_name: -> { Faker::Name.name },
  },
  legal_aid_application_transaction_types: {},
  legal_aid_applications: {},
  legal_framework_merits_task_lists: {},
  legal_framework_submission_histories: {},
  legal_framework_submissions: {},
  linked_applications: {},
  malware_scan_results: {
    file_details: {},
    # this is a JSON block that contains the original filename
    # this has the potential to leak the applicant name
    # e.g. jane_smith_statement_of_case.doc, etc
  },
  matter_oppositions: {
    reason: -> { Faker::Lorem.sentence },
  },
  offices: {
    code: -> { Faker::Base.regexify(/^[0-9][A-Z][0-9]{3}[A-Z]$/) },
  },
  offices_providers: {},
  opponents: {
    first_name: -> { Faker::Name.first_name },
    last_name: -> { Faker::Name.last_name },
  },
  opponents_applications: {
    reason_for_applying: -> { Faker::Lorem.sentence },
  },
  organisations: {
    name: -> { Faker::Company.name },
  },
  other_assets_declarations: {},
  parties_mental_capacities: {
    understands_terms_of_court_order_details: -> { Faker::Lorem.sentence },
  },
  partners: {
    first_name: -> { Faker::Name.first_name },
    last_name: -> { Faker::Name.last_name },
    date_of_birth: -> { Faker::Date.birthday },
    national_insurance_number: -> { Faker::Base.regexify(NINO_REGEXP) },
  },
  permissions: {},
  policy_disregards: {},
  proceedings: {},
  proceedings_linked_children: {},
  prohibited_steps: {
    details: -> { Faker::Lorem.sentence },
  },
  providers: {
    username: -> { "#{Faker::Internet.username}_#{Random.rand(1...999).to_s.rjust(3, '0')}" },
    name: -> { Faker::Name.name },
    email: -> { Faker::Internet.email },
  },
  provider_dismissed_announcements: {},
  regular_transactions: {},
  savings_amounts: {},
  scheduled_mailings: {
    # Should we just not export this?
    # The potential PII (email) is embedded in a JSON block
    arguments: -> { {} },
    addressee: -> { Faker::Internet.email },
  },
  scope_limitations: {},
  schedules: {},
  statement_of_cases: {
    statement: -> { Faker::Lorem.sentence },
  },
  settings: {},
  specific_issues: {
    details: -> { Faker::Lorem.sentence },
  },
  state_machine_proxies: {},
  transaction_types: {},
  true_layer_banks: {},
  undertakings: {
    additional_information: -> { Faker::Lorem.sentence },
  },
  uploaded_evidence_collections: {},
  urgencies: {
    nature_of_urgency: -> { Faker::Lorem.sentence },
    additional_information: -> { Faker::Lorem.sentence },
  },
  vary_orders: {
    details: -> { Faker::Lorem.sentence },
  },
  vehicles: {},
}
@rules
