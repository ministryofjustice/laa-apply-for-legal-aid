Feature: Enhanced bank upload check your answers
  @javascript
  Scenario: I am able to view and amend provider means answers for enhanced bank upload flow
    Given csrf is enabled
    And the feature flag for enhanced_bank_upload is enabled
    And I have completed a non-passported employed application with enhanced bank upload as far as the end of the means section
    Then I should be on the "means_summary" page showing "Check your answers"

    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h3  | Bank statements |
      | h2  | Your client's income |
      | h3  | Employment income |
      | h3  | What payments does your client receive? |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | What payments does your client make? |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does your client have? |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |

    And I should see "Uploaded bank statements"
    And I should see 'Does your client receive student finance?'
    And I should not see 'Does your client have any savings accounts they cannot access online?'

    When I click Check Your Answers Change link for "bank statements"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "hello_world.pdf UPLOADED"

    When I click "Save and continue"

    Then I should be on the "means_summary" page showing "Check your answers"
    And I should see "hello_world.pdf"

    When I click Check Your Answers Change link for "What payments does your client receive?"
    Then I should be on the "regular_incomes" page showing "Which of the following payments does your client receive?"

    When I check "Benefits"
    And I fill "Benefits amount" with "1000"
    And I choose "providers-means-regular-income-form-benefits-frequency-two-weekly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client receives in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"
    And I should see "1,000.00"
    And I should see "Every two weeks"

    When I click Check Your Answers Change link for "What payments does your client receive?"
    Then I should be on the "regular_incomes" page showing "Which of the following payments does your client receive?"

    When I check "My client receives none of these payments"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"

    When I click Check Your Answers Change link for "student finance"
    And I choose "Yes"
    And I enter amount "5000"

    When I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"
    And the answer for "student finance question" should be "Yes"
    And the answer for "student finance annual amount" should be "£5,000"

    When I click Check Your Answers Change link for "What payments does your client make?"
    Then I should be on the "regular_outgoings" page showing "Which of the following payments does your client make?"
    And I check "Maintenance payments to a former partner"
    And I fill "Maintenance out amount" with "500"
    And I choose "providers-means-regular-outgoings-form-maintenance-out-frequency-monthly-field"

    And I click "Save and continue"
    Then I should be on a page with title "Select payments your client makes in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"
    And I should see "£500.00"
    And I should see "Monthly"

    When I click Check Your Answers Change link for "What payments does your client make?"
    Then I should be on the "regular_outgoings" page showing "Which of the following payments does your client make?"
    And I check "Housing payments"
    And I fill "Rent or mortgage amount" with "500"
    And I choose "providers-means-regular-outgoings-form-rent-or-mortgage-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on the "housing_benefits" page showing "Does your client receive housing benefits?"

    When I choose "Yes"
    And I enter amount "100"
    And I choose "Every week"

    And I click "Save and continue"
    Then I should be on a page with title "Select payments your client makes in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"

    When I click Check Your Answers Change link for "What payments does your client make?"
    Then I should be on the "regular_outgoings" page showing "Which of the following payments does your client make?"
    And I check "My client makes none of these payments"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"
