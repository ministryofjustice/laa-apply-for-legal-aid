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
    Then I should be on a page showing "Select any types of income you receive"
    Then I click "Save and continue"
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

  @javascript
  Scenario: I want to change property details via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Own home'
    Then I should be on a page showing 'Do you own the home that you live in?'
    Then I click 'Continue'
    Then I should be on a page showing 'How much is your home worth?'
    Then I fill 'Property value' with '500000'
    Then I click 'Continue'
    Then I should be on a page showing 'What is the outstanding mortgage on your home?'
    Then I click 'Continue'
    Then I should be on a page showing 'Do you own your home with anyone else?'
    Then I click 'Continue'
    Then I should be on a page showing 'What % share of your home do you legally own?'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£500,000.00'
    And the answer for 'Outstanding mortgage' should be '£100,000.00'
    And the answer for 'Shared ownership' should be 'Yes, a partner or ex-partner'
    And the answer for 'Percentage home' should be '50.00%'

  @javascript
  Scenario: I want to remove property details via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Own home'
    Then I should be on a page showing 'Do you own the home that you live in?'
    Then I choose 'No'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Own home' should be 'No'

  @javascript
  Scenario: I want to return to the check your answers page without changing property details
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Own home'
    Then I should be on a page showing 'Do you own the home that you live in?'
    Then I click 'Continue'
    Then I should be on a page showing 'How much is your home worth?'
    Then I click 'Continue'
    Then I should be on a page showing 'What is the outstanding mortgage on your home?'
    Then I click 'Continue'
    Then I should be on a page showing 'Do you own your home with anyone else?'
    Then I click 'Continue'
    Then I should be on a page showing 'What % share of your home do you legally own?'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000.00'
    And the answer for 'Outstanding mortgage' should be '£100,000.00'
    And the answer for 'Shared ownership' should be 'Yes, a partner or ex-partner'
    And the answer for 'Percentage home' should be '50.00%'

  @javascript
  Scenario: I want to change savings via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on a page showing 'Do you have any savings and investments?'
    Then I fill 'Cash' with '1000'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Savings and investments' should be 'Cash savings'
    And the answer for 'Savings and investments' should be '£1,000.00'

  @javascript
  Scenario: I want to add savings via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on a page showing 'Do you have any savings and investments?'
    Then I select 'Post Office, ISAs and other savings accounts'
    Then I fill 'Isa' with '5000'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Savings and investments' should be 'Post Office, ISAs and other savings accounts'
    And the answer for 'Savings and investments' should be '£5,000.00'

  @javascript
  Scenario: I want to remove savings via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on a page showing 'Do you have any savings and investments?'
    Then I deselect 'Cash savings'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Savings and investments' should be 'None declared'

  @javascript
  Scenario: I return to the check your answers page without changing savings
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on a page showing 'Do you have any savings and investments?'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Savings and investments' should be 'Cash savings'
    And the answer for 'Savings and investments' should be '£100.00'

  @javascript
  Scenario: I want to change other assets via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Other assets'
    Then I should be on a page showing 'Do you have any of the following?'
    Then I fill 'Land value' with '1234.56'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Other assets' should be 'Land'
    And the answer for 'Other assets' should be '£1,234.56'

  @javascript
  Scenario: I want to add other assets via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Other assets'
    Then I should be on a page showing 'Do you have any of the following?'
    Then I select 'Timeshare'
    Then I fill 'Timeshare value' with '10000'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Other assets' should be 'Timeshare'
    And the answer for 'Other assets' should be '£10,000.00'

  @javascript
  Scenario: I want to remove other assets via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Other assets'
    Then I should be on a page showing 'Do you have any of the following?'
    Then I deselect 'Land'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Other assets' should be 'None declared'

  @javascript
  Scenario: I return to the check your answers page without changing other assets
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Other assets'
    Then I should be on a page showing 'Do you have any of the following?'
    Then I click 'Continue'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Other assets' should be 'Land'
    And the answer for 'Other assets' should be '£50,000.00'

  @javascript
  Scenario: I want to add restrictions via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Restrictions'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I select 'Restraint or freezing order'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Restrictions' should be 'Restraint or freezing order'

  @javascript
  Scenario: I want to remove capital restrictions via the check your answers page
    Given I complete the citizen journey as far as check your answers
    And I click Check Your Answers Change link for 'Restrictions'
    Then I should be on a page showing 'Do any restrictions apply to your property, savings or assets?'
    Then I deselect 'Bankruptcy'
    Then I deselect 'Held overseas'
    Then I click 'Continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Restrictions' should be 'None declared'
