Feature: partner_means_assessment full journey
  @javascript
  Scenario: I am able to complete a minimal (answering no to everything) partner income means assessment to check your answers
    Given csrf is enabled
    And the feature flag for partner_means_assessment is enabled
    And I complete the partner journey as far as 'about financial means'

    When I click 'Save and continue'
    Then I should be on a page with title "What is the partner's employment status?"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Upload the partner's bank statements"

    When I upload the fixture file named "acceptable.pdf"
    Then I should see "acceptable.pdf UPLOADED"

    When I click "Save and continue"
    Then I should be on a page with title "Does the partner get any benefits"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Which of these payments does the partner get?"

    When I select "The partner does not get any of these payments"
    And I click "Save and continue"
    Then I should be on a page with title "Does the partner get student finance?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Which of these payments does the partner pay?"

    When I select "The partner makes none of these payments"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have any dependants?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Check your answers"

  @javascript
  Scenario: I am able to complete the income means assessment for client and partner to check your answers
    Given csrf is enabled
    And the feature flag for partner_means_assessment is enabled
    And I have completed a non-passported unemployed application with bank statements as far as the open banking consent page
    And I have added a partner
    Then I should be on a page showing "Does your client use online banking?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Upload your client's bank statements"

    Given I upload the fixture file named "acceptable.pdf"
    Then I should see "acceptable.pdf UPLOADED"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does your client get any benefits?"
    And I choose "No"

    When I click "Save and continue"
    Then I should be on the "regular_incomes" page showing "Which of these payments does your client get?"

    When I check "Pension"
    And I fill "Pension amount" with "100"
    And I choose "providers-means-regular-income-form-pension-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client receives in cash"
    And I should see "Pension"

    When I select "My client receives none of these payments in cash"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client get student finance?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does your client pay?"

    When I check "Housing payments"
    And I fill "providers-means-regular-outgoings-form-rent-or-mortgage-amount-field" with "100"
    And I choose "providers-means-regular-outgoings-form-rent-or-mortgage-frequency-weekly-field"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client receive Housing Benefit?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Select payments your client pays in cash"
    And I should see "Housing payments"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Complete the partner's financial assessment"

    When I click 'Save and continue'
    Then I should be on a page with title "What is the partner's employment status?"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Upload the partner's bank statements"

    When I upload the fixture file named "acceptable.pdf"
    Then I should see "acceptable.pdf UPLOADED"

    When I click "Save and continue"
    Then I should be on a page with title "Does the partner get any benefits"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Which of these payments does the partner get?"
    And the checkbox for Pension should be unchecked

    When I select "The partner does not get any of these payments"
    And I click "Save and continue"
    Then I should be on a page with title "Does the partner get student finance?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Which of these payments does the partner pay?"


    When I check "Childcare payments"
    And I fill "providers-partners-regular-outgoings-form-child-care-amount-field" with "200"
    And I choose "providers-partners-regular-outgoings-form-child-care-frequency-weekly-field"
    And I click "Save and continue"
    Then I should be on a page with title "Select payments the partner pays in cash"
    And I should not see "Housing payments"
    
    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have any dependants?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Check your answers"
