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
    Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000'
    And the answer for 'Outstanding mortgage' should be '£100,000'
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
    Then I choose "No, they're the sole owner"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
    Then I choose 'Yes'
    And I fill 'Restrictions details' with "Restrictions include:"
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
    And the answer for 'Property value' should be '£200,000'
    And the answer for 'Outstanding mortgage' should be '£100,000'
    And the answer for 'Shared ownership' should be "No, they're the sole owner"
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
  Scenario: I am able to go back and change Bank Accounts and be taken back to the check your answers page for other assets
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'bank accounts'
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
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'bank accounts'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for all 'Bank accounts' categories should be 'No'

  @javascript
  Scenario: I am able to go back and change Savings and Investments and be taken back to the check your answers page for other assets
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'savings and investments'
    Then I should be on a page showing 'Which savings or investments does your client have?'
    Then I select 'Money not in a bank account'
    Then I fill 'cash' with '456.33'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
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
    Then I should be on a page showing 'Which savings or investments does your client have?'
    Then I select 'My client has none of these savings or investments'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for all 'Savings and investments' categories should be 'No'

  @javascript
  Scenario: I am able to go back and change Other Assets and be taken to the restrictions page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    And I click Check Your Answers Change link for 'other assets'
    Then I should be on a page showing 'Which assets does your client have?'
    Then I select 'Land'
    Then I fill 'land_value' with '20,000'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
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
    Then I should be on a page showing 'Which assets does your client have?'
    Then I select 'My client has none of these assets'
    Then I click 'Save and continue'
    Then I am on the check your answers page for other assets
    And the answer for all 'Other assets' categories should be 'No'

  @javascript
  Scenario: I am able to go back and select multiple disregards then come straight back to the check your answers page
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for policy disregards
    And I click Check Your Answers Change link for 'policy disregards'
    Then I should be on a page showing 'schemes or charities'
    Then I select 'England Infected Blood Support Scheme'
    And I select 'Vaccine Damage Payments Scheme'
    Then I click 'Save and continue'
    Then I am on the check your answers page for policy disregards
    And the answer for 'policy disregards' should be 'England Infected Blood Support Scheme'
    And the answer for 'policy disregards' should be 'Vaccine Damage Payments Scheme'

    @javascript
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
      Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'Yes, with a mortgage or loan'
      And the answer for 'Property value' should be '£500,000'

    @javascript
    Scenario: I want to remove property details via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'Own home'
      Then I should be on a page showing 'Does your client own the home that they live in?'
      Then I choose 'No'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Own home' should be 'No'

    @javascript
    Scenario: I want to view bank accounts via the capital check your answers page
      Given I complete the passported journey as far as capital check your answers
      And I click Check Your Answers Change link for 'bank accounts'
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
      Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
      Then I choose 'Yes'
      Then I fill "Restrictions details" with 'Restraint or freezing order'
      Then I click 'Save and continue'
      Then I should be on a page showing 'Check your answers'
      And the answer for 'Restrictions' should be 'Yes'
      And the answer for 'Restrictions' should be 'Restraint or freezing order'
      And I click Check Your Answers Change link for 'Restrictions'
      Then I should be on a page showing 'Is your client prohibited from selling or borrowing against their assets?'
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
      Then I choose "Yes"
      Then I fill "Payment remaining" with "2000"
      And I click "Save and continue"
      Then I should be on a page showing "Was the vehicle bought over 3 years ago?"
      Then I choose 'Yes'
      And I click "Save and continue"
      Then I should be on a page showing "Is the vehicle in regular use?"
      Then I choose "Yes"
      And I click "Save and continue"
      Then I should be on a page showing 'Check your answers'

    @javascript
    Scenario: I submit the application and view the check_your_answers page
      Given I complete the application and view the check your answers page
      Then I am on the read only version of the check your answers page
      Then I click 'Back to your applications'
      Then I should be on a page showing 'Applications'
      Then I view the previously created application
      Then I am on the read only version of the check your answers page

  @javascript
  Scenario: I am able to view and amend provider means answers for bank statement upload flow
    Given csrf is enabled
    And I have completed a non-passported employed application with bank statement upload as far as the end of the means section
    Then I should be on the 'means_summary' page showing 'Check your answers'

    And I should see 'Uploaded bank statements'
    And I should see 'Does your client receive student finance?'
    And the answer for 'student finance question' should be 'No'
    And I should not see 'Which bank accounts does your client have?'

    When I click Check Your Answers Change link for 'bank statements'
    And I upload an evidence file named 'hello_world.pdf'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And I should see 'hello_world.pdf'

    When I click Check Your Answers Change link for "What payments does your client receive?"
    And I check 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page with title 'Select payments your client receives in cash'
    When I check 'None of the above'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

    When I click Check Your Answers Change link for "What payments does your client receive?"
    And I check 'My client receives none of these payments'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

    When I click Check Your Answers Change link for 'student finance'
    And I choose 'Yes'
    And I enter amount '5000'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And the answer for 'student finance question' should be 'Yes'
    And the answer for 'student finance annual amount' should be '£5,000'

    When I click Check Your Answers Change link for "What payments does your client make?"
    And I check 'Maintenance payments to a former partner'
    And I click 'Save and continue'
    Then I should be on a page with title 'Select payments your client makes in cash'
    When I check 'None of the above'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

    When I click Check Your Answers Change link for "What payments does your client make?"
    And I check 'My client makes none of these payments'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

  @javascript
  Scenario: I am able to see all necessary sections for a non-passported open banking flow
    Given I have completed a non-passported application with open banking transactions
    And I am viewing the means summary check your anwsers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's income |
      | h3  | Employment income |
      | h3  | What payments does your client receive? |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | What payments does your client make? |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
    # | h3  | Which bank accounts does your client have? |
      | h3  | Does your client have any savings accounts they cannot access online? |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |

    And I should not see "Payments your client receives in cash"
    And I should not see "Payments your client makes in cash"

    And the "What payments does your client receive?" section's questions and answers should exist:
      | question | answer |
      | Benefits | £666.00 |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | Yes, but none specified |
      | Income from a property or lodger | None |
      | Pension | None |

    And the "What payments does your client make?" section's questions and answers should exist:
      | question | answer |
      | Housing payments | £999.00 |
      | Childcare payments | None |
      | Maintenance payments to a former partner | Yes, but none specified |
      | Payments towards legal aid in a criminal case | None |

  @javascript
  Scenario: I am able to see all necessary sections for a non-passported bank statement upload flow
    Given csrf is enabled
    And I have completed a non-passported employed application with bank statement upload as far as the end of the means section
    Then I should be on the 'means_summary' page showing 'Check your answers'

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's income |
      | h3  | Bank statements |
      | h3  | Employment income |
      | h3  | What payments does your client receive? |
      | h3  | Payments your client receives in cash |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | What payments does your client make? |
      | h3  | Payments your client makes in cash |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |

    And the "Bank statements" questions should exist:
      | question |
      | Uploaded bank statements |

    And the "What payments does your client receive?" section's questions and answers should exist:
      | question | answer |
      | Benefits | Yes |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | Yes |
      | Income from a property or lodger | None |
      | Pension | None |

    And the "Payments your client receives in cash" section's questions should exist:
      | question |
      | Benefits |

    And the "What payments does your client make?" section's questions and answers should exist:
      | question | answer |
      | Housing payments | Yes |
      | Childcare payments | None |
      | Maintenance payments to a former partner | Yes |
      | Payments towards legal aid in a criminal case | None |

    And the "Payments your client makes in cash" section's questions should exist:
      | question |
      | Housing payments |
