@javascript
Feature: Entering humanized monetary amounts on various forms
  Scenario: I can enter humanized monetary amounts like 1,000 for cash income
    Given csrf is enabled
    And I have completed a non-passported employed application for "client" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'cash_income'
    And I select "Maintenance payments from a former partner"
    And I fill "aggregated-cash-income-maintenance-in1-field" with "£2,654.33"
    And I fill "aggregated-cash-income-maintenance-in2-field" with "£3,654.33"
    And I fill "aggregated-cash-income-maintenance-in3-field" with "£4,654.33"

    When I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see "£2,654.33"
    And I should see "£3,654.33"
    And I should see "£4,654.33"

  Scenario: I can enter humanized monetary amounts like 1,000 for cash outgoings and housing benefit
    Given csrf is enabled
    And I have completed a non-passported employed application for "client" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'cash_outgoings'
    And I select "Housing payments"
    And I fill "aggregated-cash-outgoings-rent-or-mortgage1-field" with "£2,275.43"
    And I fill "aggregated-cash-outgoings-rent-or-mortgage2-field" with "£3,275.43"
    And I fill "aggregated-cash-outgoings-rent-or-mortgage3-field" with "£4,275.43"

    When I click 'Save and continue'
    Then I should be on the 'housing_benefits' page showing "Does your client get Housing Benefit?"

    When I choose "Yes"
    And I fill "providers-means-housing-benefit-form-housing-benefit-amount-field" with "£1,322.55"
    And I choose "Monthly"

    When I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see "£2,275.43"
    And I should see "£3,275.43"
    And I should see "£4,275.43"
    And I should see "£1,322.55"

  Scenario: I can enter humanized monetary amounts like 1,000 for state benefits
    Given csrf is enabled
    And I have completed a non-passported employed application for "client" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'state_benefits_question'
    And I choose "Yes"
    And I click 'Save and continue'

    Then I should be on a page with title "Add benefit, charitable or government payment details"
    And I fill 'regular-transaction-description-field' with "my government handout"
    And I fill 'regular-transaction-amount-field' with "£1,222,333.44"
    And I choose "Every week"

    When I click 'Save and continue'
    Then I should be on the 'add_other_state_benefits' page showing 'You added 1 benefit, charitable or government payment'
    And I should see "£1,222,333.44"

  Scenario: I can enter humanized monetary amounts like 1,000 for student finance
    Given csrf is enabled
    And I have completed a non-passported employed application for "client" with bank statements as far as the end of the means income section
    Then I should be on the 'check_income_answers' page showing 'Check your answers'

    When I click Check Your Answers Change link for applicant 'student_finance'
    Then I should be on a page with title "Does your client get student finance?"
    And I choose "Yes"
    And I fill 'applicant-student-finance-amount-field' with "£5,432.11"

    When I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see "£5,432.11"

  Scenario: I can enter humanized monetary amounts like 1,000 for regular income
    Given csrf is enabled
    And I have completed a non-passported employed application for "client" with bank statements as far as the end of the means income section
    Then I should be on the 'check_income_answers' page showing 'Check your answers'

    When I click Check Your Answers Change link for "Payments your client gets"
    Then I should be on a page with title "Which of these payments does your client get?"
    And I select "Financial help from friends or family"
    And I fill "Friends or family" with "£1,112.33"
    And I choose the "Monthly" frequency for "Friends or family"

    When I click 'Save and continue'
    Then I should be on a page with title "Select payments your client gets in cash"
    And I select "My client gets none of these payments in cash"
    And I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see "£1,112.33"

  Scenario: I can enter humanized monetary amounts like 1,000 for regular outgoings and housing benefit
    Given csrf is enabled
    And I have completed a non-passported employed application for "client" with bank statements as far as the end of the means income section
    Then I should be on the 'check_income_answers' page showing 'Check your answers'

    When I click Check Your Answers Change link for "Payments your client pays"
    Then I should be on a page with title "Which of these payments does your client pay?"
    And I select "Maintenance payments to a former partner"
    And I fill "Maintenance out" with "£2,322.22"
    And I choose the "Monthly" frequency for "Maintenance out"

    When I click 'Save and continue'
    Then I should be on a page with title "Select payments your client pays in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client get Housing Benefit?"

    When I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see "£2,322.22"

  Scenario: I can enter humanized monetary amounts like 1,000 for mandatory capital disregards
    Given I have completed the income and capital sections of a non-passported application with bank statement uploads
    When I am viewing the means capital check your answers page

    When I click link "Change Budgeting Advances"
    And I fill "capital-disregard-amount-field" with "£1,654.33"

    When I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
    And I should see "£1,654.33"

  Scenario: I can enter humanized monetary amounts like 1,000 for discretionary capital disregards
    Given I have completed the income and capital sections of a non-passported application with bank statement uploads
    When I am viewing the means capital check your answers page

    When I click link "Change Compensation, damages or ex-gratia payments for personal harm"
    And I fill "capital-disregard-amount-field" with "£2,321.11"

    When I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
    And I should see "£2,321.11"
