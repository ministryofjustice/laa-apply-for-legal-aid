Feature: partner means assessment employment feature

  @javascript
  Scenario: I am able to enter details of the partner's employment for a partner with no National Insurance number
    Given I complete the journey as far as the employment status page for a partner with no NI number
    When I select "Employed"
    And I click "Save and continue"
    Then I should be on a page with title "We could not check the partner's employment record with HMRC"

