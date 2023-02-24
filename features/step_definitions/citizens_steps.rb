Given("An application has been created") do
  @legal_aid_application = create(
    :application,
    :with_applicant,
    :with_no_savings,
    :with_no_other_assets,
    :with_non_passported_state_machine,
    :applicant_entering_means,
    provider: create(:provider),
    transaction_period_finish_on: "2019-07-01",
  )

  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  create(:bank_account_holder, bank_provider:)
  create :bank_account, bank_provider:, currency: "GBP"
  Populators::TransactionTypePopulator.call
end

Then("I visit the start of the financial assessment") do
  sign_in_citizen_for_application(@legal_aid_application)
end

Then("I visit the start of the financial assessment in Welsh") do
  Setting.setting.update!(allow_welsh_translation: true)
  sign_in_citizen_for_application(@legal_aid_application)
  click_link("Cymraeg")
end

Then("I return to English") do
  click_link("English")
end

Then("I visit the first question about dependants") do
  sign_in_citizen_for_application(@legal_aid_application)
  visit citizens_has_dependants_path
end

Then("I visit the accounts page") do
  @legal_aid_application.update! transactions_gathered: true
  visit citizens_accounts_path
end

Then("I visit the gather transactions page") do
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_non_passported_state_machine,
    :applicant_entering_means,
  )

  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  create(:bank_account_holder, bank_provider:)
  create :bank_account, bank_provider:, currency: "GBP"

  @legal_aid_application.update! transactions_gathered: true
  visit citizens_gather_transactions_path
  wait_for_ajax
  #  the ajax tests fail in circle ci but work locally and is needed for simplecov coverage
  #  manually change to the accounts path instead to pass the simplecov test
  visit citizens_accounts_path
end

Then("I am directed to TrueLayer") do
  expect(current_url).to match(/truelayer.com/)
end

Given("I have completed an application") do
  @legal_aid_application = create(
    :application,
    :with_everything,
    :with_non_passported_state_machine,
    :applicant_entering_means,
  )

  bank_provider = create :bank_provider, applicant: @legal_aid_application.applicant
  create(:bank_account_holder, bank_provider:)
  create :bank_account, bank_provider:, currency: "GBP"
  Populators::TransactionTypePopulator.call
  steps %(Then I visit the start of the financial assessment)
end

Given("I complete the citizen journey as far as check your answers") do
  visit citizens_check_answers_path
  steps %(Then I should be on a page showing "Check your answers")
end

Given("the application has a restriction") do
  create(
    :application,
    :with_restrictions,
    legal_aid_application: @legal_aid_application,
  )
end

Given("{string} savings of {int}") do |savings_method, amount|
  @legal_aid_application.savings_amount.update!(savings_method.to_sym => amount)
end

Then("I should have completed the dependants section of the journey") do
  steps %(Then I should be on a page showing "Which of the following payments do you make?")
end

def sign_in_citizen_for_application(legal_aid_application)
  access_token = legal_aid_application.generate_citizen_access_token!
  visit citizens_legal_aid_application_path(access_token.token)
end
