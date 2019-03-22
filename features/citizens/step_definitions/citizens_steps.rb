Given('An application has been created') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :provider_submitted,
    :with_no_savings,
    :with_no_other_assets,
    provider: create(:provider),
    state: :provider_submitted
  )

  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  create :bank_account_holder, bank_provider: bank_provider
  create :bank_account, bank_provider: bank_provider, currency: 'GBP'
  TransactionType.populate
end

Then('I visit the start of the financial assessment') do
  visit citizens_legal_aid_application_path(secure_id)
end

Then('I visit the accounts page') do
  @legal_aid_application.update! transactions_gathered: true
  visit citizens_accounts_path
end

Then('I am directed to TrueLayer') do
  expect(current_url).to match(/truelayer.com/)
end

def secure_id
  @secure_id ||= @legal_aid_application.generate_secure_id
end

Given('I have completed an application') do
  @legal_aid_application = create(
    :application,
    :with_everything,
    state: :provider_submitted
  )

  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  create :bank_account_holder, bank_provider: bank_provider
  create :bank_account, bank_provider: bank_provider, currency: 'GBP'
  TransactionType.populate
  steps %(Then I visit the start of the financial assessment)
end

Given('I complete the citizen journey as far as check your answers') do
  visit citizens_check_answers_path
  steps %(Then I should be on a page showing "Check your answers")
end

Given('the application has the restriction {string}') do |restriction_name|
  restriction = Restriction.find_or_create_by(name: restriction_name)
  create(
    :legal_aid_application_restriction,
    legal_aid_application: @legal_aid_application,
    restriction: restriction
  )
end

Given('{string} savings of {int}') do |savings_method, amount|
  @legal_aid_application.savings_amount.update!(savings_method.to_sym => amount)
end
