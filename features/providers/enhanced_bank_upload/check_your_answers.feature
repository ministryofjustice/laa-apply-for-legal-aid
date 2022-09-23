Feature: Enhanced bank upload check your answers
  @javascript
  Scenario: I am able to view and amend provider means answers for enhanced bank upload flow
    Given csrf is enabled
    And the feature flag for enhanced_bank_upload is enabled
    And I have completed a non-passported employed application with enhanced bank upload as far as the end of the means section
    Then I should be on the "means_summary" page showing "Check your answers"

    And I should see "Uploaded bank statements"
    And I should not see "Which bank accounts does your client have?"

    When I click Check Your Answers Change link for "bank statements"
    And I upload an evidence file named "hello_world.pdf"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"
    And I should see "hello_world.pdf"

    When I click Check Your Answers Change link for "What payments does your client receive?"
    Then I should be on the "regular_incomes" page showing "Which of the following payments does your client receive?"

    When I check "Benefits"
    And I fill "Benefits amount" with "1000"
    And I choose "providers-means-regular-income-form-benefits-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client receives in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"

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
    And I check "Maintenance payments to a former partner"

    And I click "Save and continue"
    Then I should be on a page with title "Select payments your client makes in cash"

    When I check "None of the above"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"

    When I click Check Your Answers Change link for "What payments does your client make?"
    And I check "My client makes none of these payments"
    And I click "Save and continue"
    Then I should be on the "means_summary" page showing "Check your answers"
