Given("I have completed a non-passported employed application and reached the open banking consent with bank statement upload enabled") do
  # These changes are to add existing categories (as would have been selected by the applicant)
  # to the application e.g. housing, benefits, the categories are now selected by the provider
  # so should not be necessary, however in practice this means that the checkboxes are not being populated
  # on the page for the transactions pages so I have made the tests pass in the current format for now.
  @applicant = create(:applicant, :employed, with_bank_accounts: 1)

  @legal_aid_application = create(
    :application,
    :with_single_employment,
    :with_extra_employment_information,
    :with_non_passported_state_machine,
    :provider_confirming_applicant_eligibility,
    :with_proceedings,
    applicant: @applicant,
    explicit_proceedings: %i[se014 da001],
    transaction_period_finish_on: "2022-07-08",
  )

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider

  bank_account = @applicant.bank_accounts.first
  create_list :bank_transaction, 2, :credit, bank_account: bank_account, amount: rand(1...1_500.0).round(2)
  create_list :bank_transaction, 3, :debit, bank_account: bank_account,  amount: rand(1...1_500.0).round(2)

  visit(providers_legal_aid_application_open_banking_consents_path(@legal_aid_application))
end

Given("I have completed a non-passported employed application with bank statement upload as far as the end of the means section") do
  @legal_aid_application = create(
    :application,
    :with_proceedings,
    :with_employed_applicant,
    :with_single_employment,
    :with_extra_employment_information,
    :without_open_banking_consent,
    :with_fixed_benefits_cash_transactions,
    :with_maintenance_in_category,
    :with_fixed_rent_or_mortage_cash_transactions,
    :with_maintenance_out_category,
    :with_own_home_mortgaged,
    :with_policy_disregards,
    :with_non_passported_state_machine,
    :checking_non_passported_means,
    explicit_proceedings: %i[se014 da001],
    transaction_period_finish_on: "2022-07-08",
  )

  create :attachment, :bank_statement, legal_aid_application: @legal_aid_application

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_means_summary_path(@legal_aid_application))
end

Given "I have completed a non-passported employed application with enhanced bank upload as far as the end of the means section" do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_single_employment,
    :with_extra_employment_information,
    :without_open_banking_consent,
    :checking_non_passported_means,
  )

  create :attachment, :bank_statement, legal_aid_application: @legal_aid_application

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_means_summary_path(@legal_aid_application))
end
