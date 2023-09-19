Feature: partner_means_assessment full journey
  @javascript
  Scenario: I am able to complete a minimal (answering no to everything) partner capital assessment to check your answers
    Given csrf is enabled
    And the feature flag for partner_means_assessment is enabled
    And I complete the partner journey as far as capital introductions
    
    When I click 'Continue'
    Then I should be on a page with title "Does your client or their partner own the home your client lives in?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client or their partner own a vehicle?"
