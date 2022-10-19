Given "I have completed a non-passported employed application with enhanced bank upload as far as the open banking consent page" do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_single_employment,
    :with_extra_employment_information,
    :with_non_passported_state_machine,
    :provider_confirming_applicant_eligibility,
  )

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_open_banking_consents_path(@legal_aid_application))
end

Given "I have completed a non-passported employed application with enhanced bank upload as far as the end of the means section" do
  @legal_aid_application = create(
    :legal_aid_application,
    :with_proceedings,
    :with_employed_applicant,
    :with_single_employment,
    :with_extra_employment_information,
    :with_rent_or_mortgage_regular_transaction,
    :with_housing_benefit_regular_transaction,
    :with_savings_amount,
    :with_policy_disregards,
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
