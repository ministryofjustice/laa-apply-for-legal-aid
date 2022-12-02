Given("I have completed a bank statement upload application with merits") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_single_employment,
    :with_everything,
    :with_dependant,
    :with_cfe_empty_result,
    :with_extra_employment_information,
    :with_full_employment_information,
    :with_fixed_benefits_cash_transactions,
    :with_fixed_rent_or_mortage_cash_transactions,
    :with_chances_of_success,
    provider_received_citizen_consent: false,
    attachments: [build(:attachment, :bank_statement)],
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!
  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

Given("I have completed an enhanced bank statement upload application with merits") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_rent_or_mortgage_regular_transaction,
    :with_merits_statement_of_case,
    :with_opponent,
    :with_restrictions,
    :with_incident,
    :with_vehicle,
    :with_transaction_period,
    :with_extra_employment_information,
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

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!
  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

Given("I have completed truelayer application with merits") do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_non_passported_state_machine,
    :with_restrictions,
    :with_vehicle,
    :with_transaction_period,
    :with_extra_employment_information,
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
    :with_incident,
    :with_chances_of_success,
    :with_irregular_income,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
  )

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!
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
    :with_extra_employment_information,
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
    :with_incident,
    :with_chances_of_success,
    property_value: 599_999.99,
    outstanding_mortgage_amount: 399_999.99,
    shared_ownership: "partner_or_ex_partner",
    percentage_home: 33.33,
    explicit_proceedings: %i[da002 da006],
    set_lead_proceeding: :da002,
    student_finance: false,
  )
  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider
end

Given("I have completed a passported application with merits") do
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

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!
  create :legal_framework_merits_task_list, :da002_da006_as_applicant, legal_aid_application: @legal_aid_application

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
    :with_incident,
    :with_chances_of_success,
  )

  create :legal_framework_merits_task_list, :da001, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider
end

When("I view the review and print your application page") do
  visit(providers_legal_aid_application_review_and_print_application_path(@legal_aid_application))
end

Then("the \"Income, regular payments and assets\" review section should contain:") do |table|
  expectations = table.hashes.map(&:symbolize_keys)

  within(".income_payments_and_assets") do
    expectations.each do |expectated|
      expect(page).to have_css(".govuk-table__cell", text: expectated[:question])
    end
  end
end

Then("the answer to the {string} question should be {string}") do |question, answer|
  question = find("dt", text: question)
  answer = question.sibling("dd", text: answer)
  expect(answer).to be_truthy
end
