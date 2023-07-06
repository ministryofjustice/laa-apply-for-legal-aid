Given "I have completed a non-passported employed application with bank statements as far as the open banking consent page" do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_extra_employment_information,
    :with_non_passported_state_machine,
    :provider_confirming_applicant_eligibility,
  )

  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_open_banking_consents_path(@legal_aid_application))
end

Given "I have completed a non-passported unemployed application with bank statements as far as the open banking consent page" do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant,
    :with_non_passported_state_machine,
    :provider_confirming_applicant_eligibility,
  )

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_open_banking_consents_path(@legal_aid_application))
end

Given "I have completed a non-passported employed application with bank statements as far as the end of the means income section" do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_extra_employment_information,
    :with_rent_or_mortgage_regular_transaction,
    :with_housing_benefit_regular_transaction,
    :with_savings_amount,
    :without_open_banking_consent,
    :checking_means_income,
  )

  create :attachment, :bank_statement, legal_aid_application: @legal_aid_application

  create :employment, legal_aid_application: @legal_aid_application, owner_id: @legal_aid_application.applicant.id, owner_type: "Applicant"

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_means_check_income_answers_path(@legal_aid_application))
end

Given "I have completed a non-passported non-employed application with bank statements as far as the end of the means income section" do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_applicant,
    :without_open_banking_consent,
    :checking_means_income,
  )

  create :attachment, :bank_statement, legal_aid_application: @legal_aid_application

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_means_check_income_answers_path(@legal_aid_application))
end

When(/I click (remove|change) for ['|"](.*)['|"]/) do |action, description|
  find(:xpath, "//span[contains(text(), '#{description}')]/ancestor::a[text()='#{action.camelcase}']").click
end
