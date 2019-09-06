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
    Then I click 'Save and continue'
    Then I should be on a page showing "How much is your client's home worth?"
    Then I fill "Property value" with "200000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I choose "Yes, a partner or ex-partner"
    Then I click 'Save and continue'
    Then I should be on a page showing "What % share of their home does your client legally own?"
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent your client from selling or borrowing against their assets?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000.00'
    And the answer for 'Outstanding mortgage' should be '£100,000.00'
    And the answer for 'Shared ownership' should be 'Yes, a partner or ex-partner'
    And the answer for 'Percentage home' should be '50.00%'
    And the answer for 'Restrictions' should be 'No'

  @javascript
  Scenario: I am able to go back and change no property to owned with a mortgage and not shared with a partner
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "How much is your client's home worth?"
    Then I fill "Property value" with "200000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I choose "No, sole owner"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent your client from selling or borrowing against their assets?'
    Then I choose 'Yes'
    And I fill 'Restrictions details' with "Restrictions include:"
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000.00'
    And the answer for 'Outstanding mortgage' should be '£100,000.00'
    And the answer for 'Shared ownership' should be 'No, sole owner'
    And the answer for 'Restrictions' should be 'Yes'
    And the answer for 'Restrictions' should be 'Restrictions include:'

  @javascript
  Scenario: I am able to go back and not change property owned and come straight back to check passported answers
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'No'

  @javascript
  Scenario: I am able to go back and change Savings and Investments and be taken to the restrictions page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'savings and investments'
    Then I should be on a page showing 'What types of savings or investments does your client have?'
    Then I select 'Cash savings'
    Then I fill 'cash' with '456.33'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent your client from selling or borrowing against their assets?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And I should be on a page showing "£456.33"
    And the answer for 'Restrictions' should be 'No'

  @javascript
  Scenario: I am able to go back and not change Savings and Investments to have any values then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'savings and investments'
    Then I should be on a page showing 'What types of savings or investments does your client have?'
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Savings and investments' should be 'None declared'

  @javascript
  Scenario: I am able to go back and change Other Assets and be taken to the restrictions page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'other assets'
    Then I should be on a page showing 'Which types of assets does your client have?'
    Then I select 'Land'
    Then I fill 'land_value' with '20,000'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Are there any legal restrictions that prevent your client from selling or borrowing against their assets?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And I should be on a page showing "£20,000"

  @javascript
  Scenario: I am able to go back and not change Other Assets to have any values then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'other assets'
    Then I should be on a page showing 'Which types of assets does your client have?'
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Other assets' should be 'None declared'

    @javascript @vcr
    Scenario: I want to change property value via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Own home'
      Then I should be on a page showing 'Does your client own the home that they live in?'
      Then I click 'Save and continue'
      Then I should be on a page showing "How much is your client's home worth?"
      Then I fill 'Property value' with '500000'
      Then I click 'Save and continue'
      Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
      Then I click 'Save and continue'
      Then I should be on a page showing 'Does your client own their home with anyone else?'
      Then I click 'Save and continue'
      Then I should be on a page showing 'What % share of their home does your client legally own?'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Are there any legal restrictions that prevent your client from selling or borrowing against their assets?'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
      And the answer for 'Property value' should be '£500,000.00'

    @javascript @vcr
    Scenario: I want to remove property details via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Own home'
      Then I should be on a page showing 'Does your client own the home that they live in?'
      Then I choose 'No'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'No'

    @javascript @vcr
    Scenario: I want to view savings via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Savings and investments'
      Then I should be on a page showing 'What types of savings or investments does your client have?'
      Then I click 'Save and continue'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'

    @javascript @vcr
    Scenario: I want to view other assets via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Other assets'
      Then I should be on a page showing 'Which types of assets does your client have?'
      Then I click 'Save and continue'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'

    @javascript @vcr
    Scenario: I want to add and remove restrictions via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing 'Are there any legal restrictions that prevent your client from selling or borrowing against their assets?'
      Then I choose 'Yes'
      Then I fill "Restrictions details" with 'Restraint or freezing order'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'Yes'
      And the answer for 'Restrictions' should be 'Restraint or freezing order'
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing 'Are there any legal restrictions that prevent your client from selling or borrowing against their assets?'
      Then I choose 'No'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'No'

    @javascript
    Scenario: I change vehicle answers
      Given I complete the passported journey as far as capital check your answers
      Then I click Check Your Answers Change link for 'Vehicles'
      Then I should be on a page showing 'Does your client own a vehicle?'
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
      Then I should be on a page showing "When did your client buy the vehicle?"
      Then I enter the purchase date '21-3-2002'
      And I click "Save and continue"
      Then I should be on a page showing "Is the vehicle in regular use?"
      Then I choose option "Vehicle used regularly true"
      And I click "Save and continue"
      Then I should be on a page showing 'Check your answers'

    @javascript @vcr
    Scenario: I submit the application and view the check_your_answers page
      Given I complete the application and view the check your answers page
      Then I am on the read only version of the check your answers page
      Then I click 'Back to your applications'
      Then I should be on a page showing 'Your legal aid applications'
      Then I view the previously created application
      Then I am on the read only version of the check your answers page
