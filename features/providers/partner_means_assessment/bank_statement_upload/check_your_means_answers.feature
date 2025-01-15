Feature: Bank statement upload check your answers
  @javascript
  Scenario: I can view and change answers to means income questions for non-passported, non-TrueLayer applications on behalf of employed clients and partners
    Given csrf is enabled
    And I have completed a non-passported employed application for "client and partner" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    And the following sections within "partner" should exist:
      | tag | section |
      | h2  | The partner's income |
      | h3  | Bank statements |
      | h3  | Employment income |
      | h3  | Partner benefits, charitable or government payments |
      | h3  | Payments the partner gets |
      | h3  | Student finance |
      | h2  | The partner's outgoings |
      | h3  | Payments the partner pays |
      | h3  | Payments the partner pays in cash |

    And the following sections should exist:
      | tag | section |
      | h3  | Housing benefit |
      | h2  | Dependants |

    And the following sections should not exist:
      | tag | section |
      | h2  | The partner's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does the partner have? |
      | h2  | Which savings or investments does the partner have? |
      | h2  | Which assets does the partner have? |
      | h2  | Restrictions on the partner's assets |
      | h2  | Payments from scheme or charities |

    And I should see "Uploaded bank statements"
    And I should see 'Partner gets student finance?'
    And I should not see 'Does the partner have any savings accounts they cannot access online?'

    And the "Payments the partner gets" section's questions and answers should match:
      | question | answer |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | None |
      | Income from a property or lodger | None |
      | Pension | None |

    And the "Payments the partner pays" section's questions and answers should match:
      | question | answer |
      | Housing payments | £1,600.00\ntotal in last 3 months |
      | Childcare payments | None |
      | Maintenance payments to a former partner | None |
      | Payments towards legal aid in a criminal case | None |

    And the "Housing Benefit" section's questions and answers should match:
      | question | answer |
      | Amount of Housing benefit | £1,200.00\ntotal in last 3 months |

    When I click Check Your Answers Change link for "bank statements partner"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "hello_world.pdf Uploaded"

    When I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should see "hello_world.pdf"

    When I click Check Your Answers Change link for "Payments the partner gets"
    Then I should be on the "regular_incomes" page showing "Which of these payments does the partner get?"

    When I check "Pension"
    And I fill "Pension amount" with "1000"

    And I choose "providers-partners-regular-income-form-pension-frequency-two-weekly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments the partner gets in cash"

    When I check "The partner gets none of these payments in cash"
    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should see "1,000.00"
    And I should see "every 2 weeks"

    When I click Check Your Answers Change link for "Payments the partner gets"
    Then I should be on the "regular_incomes" page showing "Which of these payments does the partner get?"

    When I check "The partner does not get any of these payments"
    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for partner 'student_finance'
    And I choose "Yes"
    And I enter amount "5000"

    When I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And the answer for "partner student finance annual amount" should be "£5,000"

    When I click Check Your Answers Change link for "Payments the partner pays"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does the partner pay?"
    And I check "Maintenance payments to a former partner"
    And I fill "Maintenance out amount" with "500"
    And I choose "providers-partners-regular-outgoings-form-maintenance-out-frequency-monthly-field"

    And I click "Save and continue"
    Then I should be on a page with title "Select payments the partner pays in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Does the partner get Housing Benefit?"

    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should see "£500.00"
    And I should see "monthly"

    When I click Check Your Answers Change link for "Payments the partner pays"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does the partner pay?"
    And I check "Housing payments"
    And I fill "Rent or mortgage amount" with "500"
    And I choose "providers-partners-regular-outgoings-form-rent-or-mortgage-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments the partner pays in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on the "housing_benefits" page showing "Does the partner get Housing Benefit?"

    When I choose "Yes"
    And I enter amount "100"
    And I choose "Every week"

    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for "Payments the partner pays"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does the partner pay?"
    And I check "The partner makes none of these payments"
    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"

  @javascript
  Scenario: On the bank upload journey, the provider has employment permissions but the partner is unemployed
    Given csrf is enabled
    And I have completed a non-passported non-employed application for "applicant and partner" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should not see 'Employment income'

    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h3  | Bank statements |
      | h2  | The partner's income |
      | h3  | Payments the partner gets |
      | h3  | Payments the partner gets in cash |
      | h3  | Student finance |
      | h2  | The partner's outgoings |
      | h3  | Payments the partner pays |
      | h3  | Payments the partner pays in cash |
      | h2  | Dependants |

    And the following sections should not exist:
      | tag | section |
      | h2  | The partner's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does the partner have? |
      | h2  | Which savings or investments does the partner have? |
      | h2  | Which assets does the partner have? |
      | h2  | Restrictions on the partner's assets |
      | h2  | Payments from scheme or charities |
