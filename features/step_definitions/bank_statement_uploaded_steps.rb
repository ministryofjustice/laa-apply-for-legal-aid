Given("I have completed a non-passported application and reached the open banking consent with bank statement upload enabled") do
  Setting.setting.update!(enable_employed_journey: true)

  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_non_passported_state_machine,
    :provider_confirming_applicant_eligibility,
    :with_proceedings,
    explicit_proceedings: %i[se014 da001],
    transaction_period_finish_on: "2022-07-08",
  )

  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.employment.*")
  @legal_aid_application.provider.permissions << Permission.find_by(role: "application.non_passported.bank_statement_upload.*")
  @legal_aid_application.provider.save!

  login_as @legal_aid_application.provider

  visit(providers_legal_aid_application_open_banking_consents_path(@legal_aid_application))
end

Given("the application's applicant is employed and has a matching HMRC response") do
  @legal_aid_application.applicant.update!(employed: true)

  matching_response = FactoryHelpers::HMRCResponse::UseCaseOne.new(SecureRandom.uuid,
                                                                   firstname: @legal_aid_application.applicant.first_name,
                                                                   lastname: @legal_aid_application.applicant.last_name,
                                                                   nino: @legal_aid_application.applicant.national_insurance_number,
                                                                   dob: @legal_aid_application.applicant.date_of_birth).response

  create(:hmrc_response,
         use_case: "one",
         response: matching_response,
         legal_aid_application: @legal_aid_application)

  # trigger after update hook to create employments/employment_payments
  @legal_aid_application.hmrc_responses.map { |hmrc_response| hmrc_response.update!(url: "my_url") }
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
