Given("I have completed a non-passported application and reached the open banking consent with bank statement upload enabled") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_non_passported_state_machine,
    :provider_confirming_applicant_eligibility,
    :with_proceedings,
    explicit_proceedings: %i[se014 da001],
    transaction_period_finish_on: "2022-07-08",
  )

  permission = Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.permissions << permission
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_open_banking_consents_path(@legal_aid_application))
end

Given("I have completed a non-passported employed application with bank statement upload as far as the end of the means section") do
  @legal_aid_application = create(
    :application,
    :with_employed_applicant,
    :with_single_employment,
    :with_non_passported_state_machine,
    :checking_non_passported_means,
    :with_proceedings,
    explicit_proceedings: %i[se014 da001],
    transaction_period_finish_on: "2022-07-08",
  )

  create :attachment, :bank_statement, legal_aid_application: @legal_aid_application

  permission = Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.permissions << permission
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_means_summary_path(@legal_aid_application))
end
