Feature: Citizen journey
  @javascript
  Scenario: Start citizen journey until TrueLayer Auth
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I should be on a page showing 'Complete your legal aid financial assessment'
    Then I click link 'Start'
    Then I should be on a page showing 'Give one-time access to your bank accounts'
    Then I click link 'Continue'
    Then I should be on a page showing 'Do you agree to share your bank transactions with us?'
    Then I select 'I agree for you to check 3 months of bank transactions'
    Then I click 'Continue'
    Then I am directed to TrueLayer

  @javascript
  Scenario: Follow citizen journey from Accounts page
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I visit the accounts page
    Then I click link 'Continue'
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "No"
    Then I click "Continue"
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
    Then I fill "Cash" with "10000"
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
