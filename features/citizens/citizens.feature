Feature: Citizen journey
  @javascript
  Scenario: Start citizen journey until TrueLayer Auth
    Given An application has been created
    And a "true layer bank" exists in the database
    Then I visit the start of the financial assessment
    Then I should be on a page showing 'Complete your legal aid financial assessment'
    Then I click link 'Start'
    Then I should be on a page showing 'Give one-time access to your bank accounts'
    Then I click link 'Continue'
    Then I should be on a page showing 'Do you agree to share your bank transactions with us?'
    Then I select 'I agree for you to check 3 months of bank transactions'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Select your bank'
    Then I choose 'HSBC'
    Then I click 'Continue'
    Then I am directed to TrueLayer

  @javascript @vcr
  Scenario: View privacy policy
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I click link "Privacy policy"
    Then I should be on a page showing "Why we need your data"
    Then I should be on a page showing "Your rights"
    Then I click link "Back"
    Then I should be on a page showing 'Complete your legal aid financial assessment'

  @javascript @webhint
  Scenario: Follow citizen journey from Accounts page
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I visit the accounts page
    Then I click link 'Continue'
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of income do you receive?"
    And I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "What regular payments do you make?"
    Then I select "Rent or mortgage"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click "Save and continue"
    Then I should be on a page showing "Declaration"
    Then I click "Agree and submit"
    Then I should be on a page showing "You've completed your financial assessment"
