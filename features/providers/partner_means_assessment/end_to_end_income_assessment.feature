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
    Then I should be on a page with title "Does your client have any dependants?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Check your answers"
