Given('An application has been created') do
  @legal_aid_application = create(
    :application,
    :with_everything,
    provider: create(:provider),
    state: :provider_submitted
  )

  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  create :bank_account_holder, bank_provider: bank_provider
  create :bank_account, bank_provider: bank_provider, currency: 'GBP'
end

Then('I visit the start of the financial assessment') do
  visit citizens_legal_aid_application_path(secure_id)
end

Then('I visit the accounts page') do
  visit citizens_accounts_path
end

Then('I am directed to TrueLayer') do
  expect(current_url).to match(/truelayer.com/)
end

def secure_id
  @secure_id ||= @legal_aid_application.generate_secure_id
end
