Feature: Checking answers backwards and forwards

  @javascript
  Scenario: I am able to go back and change no property to owned with a mortgage and shared with a partner
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's home"
    And I should be on a page showing "How much is left to pay on the mortgage?"
    Then I fill "Property value" with "200000"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I choose "Yes, an ex-partner"
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client banned from selling or borrowing against their assets?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000'
    And the answer for 'Outstanding mortgage' should be '£100,000'
    And the answer for 'Shared ownership' should be 'Yes, an ex-partner'
    And the answer for 'Percentage home' should be '50.00%'
    And the answer for 'Restrictions' should be 'No'

  @javascript
  Scenario: I am able to go back and change no property to owned with a mortgage and not shared with a partner
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's home"
    Then I fill "Property value" with "200000"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I choose "No"
    Then I fill "Percentage home" with "100"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client banned from selling or borrowing against their assets?'
    Then I choose 'Yes'
    And I fill 'Restrictions details' with "Restrictions include:"
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000'
    And the answer for 'Outstanding mortgage' should be '£100,000'
    And the answer for 'Shared ownership' should be "No"
    And the answer for 'Restrictions' should be 'Yes'
    And the answer for 'Restrictions Details' should be 'Restrictions include:'

  @javascript
  Scenario: I am able to go back and not change property owned and come straight back to check passported answers
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'own_home'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'No'

  @javascript
  Scenario: I am able to go back and change Bank Accounts and be taken back to the check your answers page for other assets
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'offline accounts link'
    Then I should be on a page showing 'Which bank accounts does your client have?'
    Then I select 'Savings account'
    Then I fill 'offline_savings_accounts' with '678.99'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And I should be on a page showing '£678.99'
    And the answer for 'Restrictions' should be 'No'

  @javascript
  Scenario: I am able to go back and not change Bank Accounts to have any values then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'offline accounts link'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for all 'Bank accounts' categories should be 'No'

  @javascript
  Scenario: I am able to go back and change Savings and Investments and be taken back to the check your answers page for other assets
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'savings and investments'
    Then I should be on a page showing 'Which savings or investments does your client have?'
    Then I select 'Money not in a bank account'
    Then I fill 'cash' with '456.33'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client banned from selling or borrowing against their assets?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And I should be on a page showing "£456.33"
    And the answer for 'Restrictions' should be 'No'

  @javascript
  Scenario: I am able to go back and not change Savings and Investments to have any values then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'savings and investments'
    Then I should be on a page showing 'Which savings or investments does your client have?'
    Then I select 'None of these savings or investments'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for all 'Savings and investments' categories should be 'No'

  @javascript
  Scenario: I am able to go back and change Other Assets and be taken to the restrictions page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'other assets'
    Then I should be on a page showing 'Which assets does your client have?'
    Then I select 'Land'
    Then I fill 'land_value' with '20,000'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client banned from selling or borrowing against their assets?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And I should be on a page showing "£20,000"

  @javascript
  Scenario: I am able to go back and not change Other Assets to have any values then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'other assets'
    Then I should be on a page showing 'Which assets does your client have?'
    Then I select 'None of these assets'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for all 'Other assets' categories should be 'No'

  @javascript
  Scenario: I am able to go back and select multiple disregards then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I am on the check your answers page for policy disregards
    And I click Check Your Answers Change link for 'policy disregards'
    Then I should be on a page showing 'schemes or trusts'
    Then I select 'England Infected Blood Support Scheme'
    And I select 'Vaccine Damage Payments Scheme'
    Then I click 'Save and continue'
    Then I am on the check your answers page for policy disregards
    And the "policy disregards items" list's questions and answers should match:
      | question | answer |
      | England Infected Blood Support Scheme | Yes |
      | Vaccine Damage Payments Scheme | Yes |
      | Variant Creutzfeldt-Jakob disease (vCJD) Trust | No |
      | Criminal Injuries Compensation Scheme | No |
      | National Emergencies Trust (NET) | No |
      | We Love Manchester Emergency Fund | No |
      | The London Emergencies Trust | No |

    @javascript
    Scenario: I want to change property value via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Own home'
      Then I should be on a page showing 'Does your client own the home they usually live in?'
      Then I click 'Save and continue'
      Then I should be on a page showing "Your client's home"
      Then I fill 'Property value' with '500000'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Is your client banned from selling or borrowing against their assets?'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
      And the answer for 'Property value' should be '£500,000'

    @javascript
    Scenario: I want to remove property details via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Own home'
      Then I should be on a page showing 'Does your client own the home they usually live in?'
      Then I choose 'No'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'No'

    @javascript
    Scenario: I want to view bank accounts via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'offline accounts link'
      Then I should be on a page showing "Which bank accounts does your client have?"
      Then I select 'None of these'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'

    @javascript
    Scenario: I want to view savings via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Savings and investments'
      Then I should be on a page showing 'Which savings or investments does your client have?'
      Then I click 'Save and continue'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'

    @javascript
    Scenario: I want to view other assets via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Other assets'
      Then I should be on a page showing 'Which assets does your client have?'
      Then I click 'Save and continue'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'

    @javascript
    Scenario: I want to add and remove restrictions via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing 'Is your client banned from selling or borrowing against their assets?'
      Then I choose 'Yes'
      Then I fill "Restrictions details" with 'Restraint or freezing order'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'Yes'
      And the answer for 'Restrictions details' should be 'Restraint or freezing order'
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing 'Is your client banned from selling or borrowing against their assets?'
      Then I choose 'No'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'No'

    @javascript
    Scenario: I change vehicle answers
      Given I complete the passported journey as far as capital check your answers
      Then I click Check Your Answers Change link for 'Vehicles'
      Then I should be on a page showing 'Does your client have any other vehicles?'
      Then I choose 'No'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      Then I click Check Your Answers Change link for vehicle "1"
      Then I should be on a page with title "Amend vehicle details"
      And I should see "How much is the vehicle worth?"
      And I should see "Are there any payments left on the vehicle?"
      And I should see "Was the vehicle bought over 3 years ago?"
      And I should see "Is the vehicle in regular use?"
      Then I fill "Estimated value" with "4000"
      And I answer "Are there any payments left on the vehicle?" with "Yes"
      Then I fill "Payment remaining" with "2000"
      And I answer "Was the vehicle bought over 3 years ago?" with "Yes"
      And I answer "Is the vehicle in regular use?" with "Yes"
      And I click "Save and continue"
      Then I should be on a page showing 'Check your answers'
      And the "remaining payments" answer for vehicle 1 should be "£2,000"

      Then I click Check Your Answers Change link for vehicle "1"
      Then I should be on a page showing "Are there any payments left on the vehicle?"
      And I change "Are there any payments left on the vehicle?" to "No"
      And I click "Save and continue"
      Then I should be on a page showing 'Check your answers'
      And the "remaining payments" answer for vehicle 1 should be "£0"
      When I click Check Your Answers Change link for vehicle "1"
      Then I should be on a page showing "Are there any payments left on the vehicle?"
      And the radio button response for "Vehicle payments remain" should be "No"

    @javascript
    Scenario: I submit the application and view the check_your_answers page
      Given I complete the application and view the check your answers page
      Then I am on the read only version of the check your answers page
      Then I click 'Back to your applications'
      Then I should be on a page showing 'Your applications'
      Then I click link "In progress"
      Then I view the previously created application
      Then I am on the read only version of the check your answers page

  @javascript
  Scenario: I am able to see all necessary income sections for a non-passported open banking flow
    Given I have completed the income section of a non-passported application with open banking transactions
    And I am viewing the means income check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's income |
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h2  | Dependants |

    And I should not see "Payments your client receives in cash"
    And I should not see "Payments your client makes in cash"

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h3  | Your client's accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |

    And the "Payments your client receives" section's questions and answers should match:
      | question | answer |
      | Benefits, charitable or government payments | £666.00 |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | Yes, but none specified |
      | Income from a property or lodger | None |
      | Pension | None |

    And the "Payments your client makes" section's questions and answers should match:
      | question | answer |
      | Housing payments | £999.00 |
      | Childcare payments | None |
      | Maintenance payments to a former partner | Yes, but none specified |
      | Payments towards legal aid in a criminal case | None |

  @javascript
  Scenario: I am able to see all necessary capital sections for a non-passported open banking flow
    Given I have completed the income and capital sections of a non-passported application with open banking transactions
    And I am viewing the means capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h3  | Your client's accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h3  | "Payments your client receives in cash" |
      | h3  | "Payments your client makes in cash"    |
