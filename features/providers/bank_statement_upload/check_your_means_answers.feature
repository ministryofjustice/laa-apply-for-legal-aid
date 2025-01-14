Feature: Bank statement upload check your answers
  @javascript
  Scenario: I can view and change answers to means income questions for non-passported, non-TrueLayer applications on behalf of employed clients
    Given csrf is enabled
    And I have completed a non-passported employed application for "client" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    And the following sections within "applicant" should exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Bank statements |
      | h3  | Employment income |
      | h3  | Client benefits, charitable or government payments |
      | h3  | Payments your client gets |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client pays in cash |

    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h3  | Housing Benefit |
      | h2  | Dependants |

    And the following sections should not exist:
      | tag | section |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does your client have? |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |

    And I should see "Uploaded bank statements"
    And I should see 'Client gets student finance?'
    And I should not see "Your client's accounts"

    And the "Payments your client gets" section's questions and answers should match:
      | question | answer |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | None |
      | Income from a property or lodger | None |
      | Pension | None |

    And the "Payments your client pays" section's questions and answers should match:
      | question | answer |
      | Housing payments | £1,600.00\nTotal in last 3 months |
      | Childcare payments | None |
      | Maintenance payments to a former partner | None |
      | Payments towards legal aid in a criminal case | None |

    And the "Housing Benefit" section's questions and answers should match:
      | question | answer |
      | Does your client get Housing Benefit? | Yes |
      | Amount | £1,200.00\nTotal in last 3 months |

    When I click Check Your Answers Change link for "bank statements client"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "hello_world.pdf Uploaded"

    When I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should see "hello_world.pdf"

    When I click Check Your Answers Change link for "Payments your client gets"
    Then I should be on the "regular_incomes" page showing "Which of these payments does your client get?"

    When I check "Pension"
    And I fill "Pension amount" with "1000"
    And I choose "providers-means-regular-income-form-pension-frequency-two-weekly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client gets in cash"

    When I check "My client gets none of these payments in cash"
    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should see "1,000.00"
    And I should see "Every 2 weeks"

    When I click Check Your Answers Change link for "Payments your client gets"
    Then I should be on the "regular_incomes" page showing "Which of these payments does your client get?"

    When I check "My client does not get any of these payments"
    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'student_finance'
    And I choose "Yes"
    And I enter amount "5000"

    When I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And the answer for "applicant student finance question" should be "Yes"
    And the answer for "student finance annual amount" should be "£5,000"

    When I click Check Your Answers Change link for "Payments your client pays"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does your client pay?"
    And I check "Maintenance payments to a former partner"
    And I fill "Maintenance out amount" with "500"
    And I choose "providers-means-regular-outgoings-form-maintenance-out-frequency-monthly-field"

    And I click "Save and continue"
    Then I should be on a page with title "Select payments your client pays in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client get Housing Benefit?"

    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should see "£500.00"
    And I should see "Monthly"

    When I click Check Your Answers Change link for "Payments your client pays"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does your client pay?"
    And I check "Housing payments"
    And I fill "Rent or mortgage amount" with "500"
    And I choose "providers-means-regular-outgoings-form-rent-or-mortgage-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client pays in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on the "housing_benefits" page showing "Does your client get Housing Benefit?"

    When I choose "Yes"
    And I enter amount "100"
    And I choose "Every week"
    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for "Payments your client pays"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does your client pay?"
    And I check "My client makes none of these payments"
    And I click "Save and continue"
    Then I should be on the "check_income_answers" page showing "Check your answers"

  @javascript
  Scenario: On the bank upload journey, the provider has employment permissions but the applicant is unemployed
    Given csrf is enabled
    And I have completed a non-passported non-employed application for "applicant" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"
    And I should not see 'Employment income'
    And the following sections within 'applicant' should exist:
      | tag | section |
      | h3  | Bank statements |
      | h2  | Your client's income |
      | h3  | Payments your client gets |
      | h3  | Payments your client gets in cash |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client pays in cash |

    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Dependants |

    And the following sections should not exist:
      | tag | section |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does your client have? |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
