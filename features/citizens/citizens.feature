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
#    Then I should be on a page showing "Do you have any dependants?"
#    Then I choose "No"
#    Then I click 'Save and continue'
    Then I should be on a page showing "What regular payments do you make?"
    Then I select "Rent or mortgage"
    Then I click 'Save and continue'
#    Then I should be on a page showing "Do you own the home that you live in?"
#    Then I choose "Yes, with a mortgage or loan"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "How much is your home worth?"
#    Then I fill "Property value" with "200000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "What is the outstanding mortgage on your home?"
#    Then I fill "Outstanding mortgage amount" with "100000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Do you own your home with anyone else?"
#    Then I choose "Yes, a partner or ex-partner"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "What % share of your home do you legally own?"
#    Then I fill "Percentage home" with "50"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Do you own a vehicle?"
#    Then I choose "Yes"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "What is the estimated value of the vehicle?"
#    Then I fill "Estimated value" with "5000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Are there any payments left on the vehicle?"
#    Then I choose "Yes"
#    Then I fill "Payment remaining" with "1000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "When did you buy the vehicle?"
#    Then I enter the purchase date '21-3-2002'
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Is the vehicle in regular use?"
#    Then I choose "Yes"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "What types of savings or investments do you have?"
#    Then I select "Money not in a bank account"
#    Then I fill "Cash" with "100"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Which types of assets do you have?"
#    Then I select "Land"
#    Then I fill "Land value" with "50000"
#    Then I click 'Save and continue'
#    Then I should be on a page showing "Are there any legal restrictions that prevent you from selling or borrowing against your assets?"
#    Then I choose 'Yes'
#    Then I fill "Restrictions details" with "Yes, there are restrictions. They include..."
#    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click "Save and continue"
    Then I should be on a page showing "Declaration"
    Then I click "Agree and submit"
    Then I should be on a page showing "You've completed your financial assessment"

  @javascript
  Scenario: I want to change incomings via the check your answers page
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    Then I should be on a page showing 'Income from a property or lodger No'
    And I click Check Your Answers Change link for 'incomings'
    Then I should be on a page showing 'Which types of income do you receive?'
    Then I select 'Income from a property or lodger'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And I should be on a page showing 'Income from a property or lodger Yes'

  @javascript
  Scenario: I want to change property details via the check your answers page
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Own home'
    Then I should be on a page showing 'Do you own the home that you live in?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'How much is your home worth?'
    Then I fill 'Property value' with '500000'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What is the outstanding mortgage on your home?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you own your home with anyone else?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What % share of your home do you legally own?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I choose 'Yes'
    Then I fill "Restrictions details" with "Yes, there are restrictions. They include..."
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£500,000.00'
    And the answer for 'Restrictions' should be 'Yes'
    And the answer for 'Restrictions' should be 'Yes, there are restrictions. They include...'

  @javascript
  Scenario: I want to remove property details via the check your answers page
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Own home'
    Then I should be on a page showing 'Do you own the home that you live in?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Own home' should be 'No'

  @javascript
  Scenario: I want to return to the check your answers page without changing property details
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Own home'
    Then I should be on a page showing 'Do you own the home that you live in?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'How much is your home worth?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What is the outstanding mortgage on your home?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you own your home with anyone else?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What % share of your home do you legally own?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I want to change savings via the check your answers page
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on a page showing 'What types of savings or investments do you have?'
    Then I fill 'Cash' with '1000'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Savings and investments' should be 'Money not in a bank account'
    And the answer for 'Savings and investments' should be '£1,000.00'

  @javascript
  Scenario: I want to add savings via the check your answers page
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on a page showing 'What types of savings or investments do you have?'
    Then I select 'Current account'
    Then I fill 'Offline current accounts' with '5000'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Savings and investments' should be 'Current account'
    And the answer for 'Savings and investments' should be '£5,000.00'

  @javascript
  Scenario: I return to the check your answers page without changing savings
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And 'cash' savings of 100
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on a page showing 'What types of savings or investments do you have?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Savings and investments' should be 'Money not in a bank account'
    And the answer for 'Savings and investments' should be '£100.00'

  @javascript
  Scenario: I want to change other assets via the check your answers page
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Other assets'
    Then I should be on a page showing 'Which types of assets do you have?'
    Then I fill 'Land value' with '1234.56'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Other assets' should be 'Land'
    And the answer for 'Other assets' should be '£1,234.56'

  @javascript
  Scenario: I want to add other assets via the check your answers page
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Other assets'
    Then I should be on a page showing 'Which types of assets do you have?'
    Then I select 'Timeshare property'
    Then I fill 'Timeshare property value' with '10000'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Other assets' should be 'Timeshare property'
    And the answer for 'Other assets' should be '£10,000.00'

  @javascript
  Scenario: I return to the check your answers page without changing other assets
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Other assets'
    Then I should be on a page showing 'Which types of assets do you have?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I want to add restrictions via the check your answers page
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Restrictions'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Restrictions' should be 'Yes'
    And the answer for 'Restrictions' should be 'Yes, there are restrictions. They include...'

  @javascript
  Scenario: I return to the check your answers page without changing capital restrictions
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Restrictions'
    Then I should be on a page showing 'Are there any legal restrictions that prevent you from selling or borrowing against your assets?'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I change vehicle answers
    Given I skip the rest of this scenario until the questions are moved to the provider flow
    Given I have completed an application
    And I complete the citizen journey as far as check your answers
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I should be on a page showing 'Do you own a vehicle?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the estimated value of the vehicle?"
    Then I fill "Estimated value" with "4000"
    And I click "Save and continue"
    Then I should be on a page showing "Are there any payments left on the vehicle?"
    Then I choose option "Vehicle payments remain true"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "When did you buy the vehicle?"
    Then I enter the purchase date '21-3-2002'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    Then I choose option "Vehicle used regularly true"
    And I click "Save and continue"
    Then I should be on a page showing 'Check your answers'
