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
  visit citizens_accounts_path
end

Then('I am directed to TrueLayer') do
  expect(current_url).to match(/truelayer.com/)
end

def secure_id
  @secure_id ||= @legal_aid_application.generate_secure_id
end

Given('I complete the citizen journey as far as check your answers') do
  steps %(
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I visit the accounts page
    Then I click link 'Continue'
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "No"
    Then I click "Continue"

    # Select the different types of income that you receive
    #
    Then I should be on a page showing "Select any types of income you receive"
    Then I select "Salary or wages"
    Then I select "Benefits"
    Then I click "Save and continue"

    # Show the page showing the different types of income you have selected with a
    # link for each one to select those items from the transaction list
    #
    Then I should be on a page showing "Select your income"
    Then I should be on a page showing "Salary or wages"
    Then I should be on a page showing "Benefits"


    # select salary, show all the transactions, click Continue and abe taken back to the
    # same page
    Then I click on the Select from your bank statement link for income type "Salary"
    Then I should be on a page showing "Your salary or wage payments"
    Then I click "Continue"
    Then I should be on a page showing "Select your income"

    # select benefits, show all the transactions, click Continue and abe taken back to the
    # same page
    Then I click on the Select from your bank statement link for income type "Benefits"
    Then I should be on a page showing "Benefits"
    Then I click "Continue"

    Then I should be on a page showing "Select your income"
    Then I click link 'Continue'

    Then I should be on a page showing "Do you own the home that you live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click "Continue"
    Then I should be on a page showing "How much is your home worth?"
    Then I fill "Property value" with "200000"
    Then I click "Continue"
    Then I should be on a page showing "What is the outstanding mortgage on your home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click "Continue"
    Then I should be on a page showing "Do you own your home with anyone else?"
    Then I choose "Yes, a partner or ex-partner"
    Then I click "Continue"
    Then I should be on a page showing "What % share of your home do you legally own?"
    Then I fill "Percentage home" with "50"
    Then I click "Continue"
    Then I should be on a page showing "Do you have any savings and investments?"
    Then I select "Cash savings"
    Then I fill "Cash" with "100"
    Then I click "Continue"
    Then I should be on a page showing "Do you have any of the following?"
    Then I select "Land"
    Then I fill "Land value" with "50000"
    Then I click "Continue"
    Then I should be on a page showing "Do any restrictions apply to your property, savings or assets?"
    Then I select "Bankruptcy"
    Then I select "Held overseas"
    Then I click "Continue"
    Then I should be on a page showing "Check your answers"
  )
end
