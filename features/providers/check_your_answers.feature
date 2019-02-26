Feature: Checking answers backwards and forwards

  @javascript
  Scenario: I am able to go back and change no property to owned with a mortgage and shared with a partner
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click "Continue"
    Then I should be on a page showing "How much is your client's home worth?"
    Then I fill "Property value" with "200000"
    Then I click "Continue"
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click "Continue"
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I choose "Yes, a partner or ex-partner"
    Then I click "Continue"
    Then I should be on a page showing "What % share of their home does your client legally own?"
    Then I fill "Percentage home" with "50"
    Then I click "Continue"
    Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
    Then I click "Continue"
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000.00'
    And the answer for 'Outstanding mortgage' should be '£100,000.00'
    And the answer for 'Shared ownership' should be 'Yes, a partner or ex-partner'
    And the answer for 'Percentage home' should be '50.00%'

  @javascript
  Scenario: I am able to go back and change no property to owned with a mortgage and not shared with a partner
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click "Continue"
    Then I should be on a page showing "How much is your client's home worth?"
    Then I fill "Property value" with "200000"
    Then I click "Continue"
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click "Continue"
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I choose "No, sole owner"
    Then I click "Continue"
    Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
    Then I click "Continue"
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000.00'
    And the answer for 'Outstanding mortgage' should be '£100,000.00'
    And the answer for 'Shared ownership' should be 'No, sole owner'

  @javascript
  Scenario: I am able to go back and not change property owned and come straight back to check passported answers
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I click "Continue"
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'No'

  @javascript
  Scenario: I am able to go back and change Savings and Investments and be taken to the restrictions page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'savings and investments'
    Then I should be on a page showing 'Does your client have any savings and investments?'
    Then I select 'Cash savings'
    Then I fill 'cash' with '456.33'
    Then I click "Continue"
    Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
    Then I click "Continue"
    Then I am on the check your answers page for other assets
    And I should be on a page showing "£456.33"

  @javascript
  Scenario: I am able to go back and not change Savings and Investments to have any values then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'savings and investments'
    Then I should be on a page showing 'Does your client have any savings and investments?'
    Then I click "Continue"
    Then I am on the check your answers page for other assets
    And the answer for 'Savings and investments' should be 'None declared'

  @javascript
  Scenario: I am able to go back and change Other Assets and be taken to the restrictions page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'other assets'
    Then I should be on a page showing 'Does your client have any of the following?'
    Then I select 'Land'
    Then I fill 'land_value' with '20,000'
    Then I click "Continue"
    Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
    Then I click "Continue"
    Then I am on the check your answers page for other assets
    And I should be on a page showing "£20,000"

  @javascript
  Scenario: I am able to go back and not change Other Assets to have any values then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'other assets'
    Then I should be on a page showing 'Does your client have any of the following?'
    Then I click "Continue"
    Then I am on the check your answers page for other assets
    And the answer for 'Other assets' should be 'None declared'

    @javascript @vcr
    Scenario: I want to change property value via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Own home'
      Then I should be on a page showing 'Does your client own the home that they live in?'
      Then I click 'Continue'
      Then I should be on a page showing "How much is your client's home worth?"
      Then I fill 'Property value' with '500000'
      Then I click 'Continue'
      Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
      Then I click 'Continue'
      Then I should be on a page showing 'Does your client own their home with anyone else?'
      Then I click 'Continue'
      Then I should be on a page showing 'What % share of their home does your client legally own?'
      Then I click 'Continue'
      Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
      Then I click 'Continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
      And the answer for 'Property value' should be '£500,000.00'
      And the answer for 'Outstanding mortgage' should be '£100,000.00'
      And the answer for 'Shared ownership' should be 'Yes, a partner or ex-partner'
      And the answer for 'Percentage home' should be '50.00%'

    @javascript @vcr
    Scenario: I want to remove property details via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Own home'
      Then I should be on a page showing 'Does your client own the home that they live in?'
      Then I choose 'No'
      Then I click 'Continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'No'

    @javascript @vcr
    Scenario: I want to remove savings via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Savings and investments'
      Then I should be on a page showing 'Does your client have any savings and investments?'
      Then I deselect 'Cash savings'
      Then I click 'Continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Savings and investments' should be 'None declared'

    @javascript @vcr
    Scenario: I want to remove other assets via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Other assets'
      Then I should be on a page showing 'Does your client have any of the following?'
      Then I deselect 'Land'
      Then I click 'Continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Other assets' should be 'None declared'

    @javascript @vcr
    Scenario: I want to add restrictions via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
      Then I select 'Restraint or freezing order'
      Then I click 'Continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'Restraint or freezing order'

    @javascript @vcr
    Scenario: I want to remove capital restrictions via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
      Then I deselect 'Bankruptcy'
      Then I deselect 'Held overseas'
      Then I click 'Continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'None declared'

    @javascript @vcr
    Scenario: I return to the capital check your answers page without changing capital restrictions
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing "Do any restrictions apply to your client's property, savings or assets?"
      Then I click 'Continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'Bankruptcy'
      And the answer for 'Restrictions' should be 'Held overseas'
