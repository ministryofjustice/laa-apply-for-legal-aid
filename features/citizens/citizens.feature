Feature: Citizen journey
  @javascript
  Scenario: Start citizen journey until TrueLayer Auth
    Given An application has been created
    And a "true layer bank" exists in the database
    Then I visit the start of the financial assessment
    Then I should be on a page showing 'Share your financial information with us'
    Then I click link 'Start'
    Then I should be on a page showing 'Give one-time access to your bank accounts'
    Then I click link 'Continue'
    Then I should be on a page showing 'Do you agree to share your bank account information with the LAA?'
    Then I choose 'Yes'
    Then I click 'Continue'
    Then I should be on a page showing 'Select your bank'
    Then I click link "Back"
    Then I should be on a page showing 'Do you agree to share your bank account information with the LAA?'
    Then I choose 'No'
    Then I click 'Continue'
    Then I should be on a page showing 'Contact your solicitor to continue your application'
    Then I click link "Back"
    Then I should be on a page showing 'Do you agree to share your bank account information with the LAA?'
    Then I choose 'Yes'
    Then I click 'Continue'
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
    Then I should be on a page showing 'Share your financial information with us'

  @javascript @webhint @vcr
  Scenario: Follow citizen journey from Accounts page
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I visit the accounts page
    Then I click link 'Continue'
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "Yes"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you have online access'
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Contact your solicitor'
    Then I click link "Back"
    Then I should be on a page showing 'Do you have online access'
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Select your bank"
    Then I click link "Back"
    Then I click link "Back"
    Then I should be on a page showing "Do you have accounts with other banks?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of income do you receive?"
    And I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on the 'student_finance' page showing 'Do you get student finance?'
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'annual_amount' page showing 'How much student finance will you get this academic year?'
    When I enter amount '5000'
    And I click 'Save and continue'
    Then I should be on a page showing "What regular payments do you make?"
    Then I select "Rent or mortgage"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page not showing 'Excluded Benefits'
    Then I click "Save and continue"
    Then I should be on a page showing "Declaration"
    Then I click "Agree and submit"
    Then I should be on a page showing "You've shared your financial information"

  @javascript
  Scenario: I want to change income types via the check your answers page
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Benefits'
    And I click Check Your Answers Change link for 'incomings'
    Then I should be on a page showing 'Which types of income do you receive?'
    Then I select 'Financial help from friends or family'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Financial help from friends or family Yes'

  @javascript
  Scenario: I want to add another bank account via the check your answers page
    # TODO: Expand this feature
    # It should really do both:
    # 1) actually handle the true layer interaction and
    # 2) demonstrate the check_answer routing.
    # It currently only manages 2)
    Given I have completed an application
    And a "true layer bank" exists in the database
    And I complete the citizen journey as far as check your answers
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page not showing 'Account 2'
    When I visit the accounts page
    Then I should be on the 'accounts' page showing 'Your account(s)'
    When I click link 'Continue'
    Then I should be on a page showing 'Check your answers'
