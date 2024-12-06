Given("I have completed a bank statement upload application with merits") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_rent_or_mortgage_regular_transaction,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_restrictions,
    :with_incident,
    :with_vehicle,
    :with_linked_and_copied_application,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_fixed_offline_accounts,
    :with_dependant,
    :with_cfe_v5_result,
    :with_chances_of_success,
    :with_own_home_mortgaged,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
    provider_received_citizen_consent: false,
    attachments: [build(:attachment, :bank_statement)],
  )

  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

Given("I have completed truelayer application with merits") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant_with_student_loan,
    :with_non_passported_state_machine,
    :with_restrictions,
    :with_vehicle,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_savings_amount,
    :with_open_banking_consent,
    :with_consent,
    :with_dependant,
    :with_own_home_mortgaged,
    :with_cfe_v5_result,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_incident,
    :with_chances_of_success,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

Given("I have completed truelayer application with merits and no student finance") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_restrictions,
    :with_vehicle,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_savings_amount,
    :with_open_banking_consent,
    :with_consent,
    :with_dependant,
    :with_own_home_mortgaged,
    :with_cfe_v5_result,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_incident,
    :with_chances_of_success,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  @legal_aid_application.applicant.update!(student_finance: false, student_finance_amount: nil)

  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

Given(/^I have completed a passported application with merits$/) do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant_and_address,
    :with_passported_state_machine,
    :with_restrictions,
    :with_vehicle,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_fixed_offline_accounts,
    :with_own_home_mortgaged,
    :with_cfe_v5_result,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_incident,
    :with_chances_of_success,
    provider_received_citizen_consent: true,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

Given(/^I have completed a passported application with a partner with merits$/) do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant_and_partner,
    :with_passported_state_machine,
    :with_restrictions,
    :with_vehicle,
    :with_transaction_period,
    :with_other_assets_declaration,
    :with_policy_disregards,
    :with_fixed_offline_accounts,
    :with_own_home_mortgaged,
    :with_cfe_v5_result,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_incident,
    :with_chances_of_success,
    provider_received_citizen_consent: true,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  cfe_submission = create(:cfe_submission, legal_aid_application: @legal_aid_application)
  create(:cfe_v6_result, :with_partner, submission: cfe_submission, legal_aid_application: @legal_aid_application)
  create(:partner, legal_aid_application: @legal_aid_application)
  @legal_aid_application.applicant.update!(has_partner: true, partner_has_contrary_interest: false)

  login_as @legal_aid_application.provider
end

Given("I have completed a non-means tested journey with merits") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_under_18_applicant,
    :with_non_means_tested_state_machine,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_parties_mental_capacity,
    :with_domestic_abuse_summary,
    :with_incident,
    :with_chances_of_success,
  )

  create :legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

Given("I have completed a backdated special children act journey") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_applicant_and_address,
    :with_non_means_tested_state_machine, # needs updating to SCA state machine when available
    :with_merits_statement_of_case,
    :with_opponent,
    :with_proceedings,
    :with_delegated_functions_on_proceedings,
    explicit_proceedings: %i[pb059],
    set_lead_proceeding: :pb059,
    df_options: { PB059: [10.days.ago.to_date, 1.day.ago.to_date] },
  )

  @legal_aid_application.applicant.update!(email: nil)
  create :legal_framework_merits_task_list, :pb059_with_no_tasks, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

When("I view the review and print your application page") do
  visit(providers_legal_aid_application_review_and_print_application_path(@legal_aid_application))
end

Then("the \"Income, regular payments and assets\" review section should contain:") do |table|
  expectations = table.hashes.map(&:symbolize_keys)

  within(".income_payments_and_assets") do
    expectations.each do |expectated|
      expect(page).to have_css(".govuk-table__header", text: expectated[:question])
    end
  end
end

Then("the answer to the {string} question should be {string}") do |question, answer|
  question = find("dt", text: question)
  answer = question.sibling("dd", text: answer)
  expect(answer).to be_truthy
end
