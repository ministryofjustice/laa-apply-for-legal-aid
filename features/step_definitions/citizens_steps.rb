Given('An application has been created') do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :provider_submitted,
    :with_no_savings,
    :with_no_other_assets,
    provider: create(:provider),
    state: :provider_submitted,
    transaction_period_finish_at: '2019-07-01'.to_time
  )

  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  create :bank_account_holder, bank_provider: bank_provider
  create :bank_account, bank_provider: bank_provider, currency: 'GBP'
  TransactionType.populate
end

Then('I visit the start of the financial assessment') do
  visit citizens_legal_aid_application_path(secure_id)
end

Then('I visit the first question about dependants') do
  visit citizens_legal_aid_application_path(secure_id)
  visit citizens_has_dependants_path
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

Given('the application has a restriction') do
  create(
    :application,
    :with_restrictions,
    legal_aid_application: @legal_aid_application
  )
end

Given('{string} savings of {int}') do |savings_method, amount|
  @legal_aid_application.savings_amount.update!(savings_method.to_sym => amount)
end

Then('I should have completed the dependants section of the journey') do
  steps %(Then I should be on a page showing "What regular payments do you make?")
end
