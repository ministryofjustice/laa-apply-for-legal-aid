Feature: non_passported_journey used delegated functions
  @javascript
  Scenario: Fill in the Applicant employment information after negative benefit check result and used delegated functions
    Given I start the application with a negative benefit check result
    And I used delegated functions
    Then I should be on a page showing "DWP records show that your client does not receive a passporting benefit"
    When I choose 'Yes'
    Then I click 'Save and continue'
    And I should be on a page with title "What is your client's employment status?"
    And I select "None of the above"
    When I click 'Save and continue'
    Then I should be on a page with title "Do you want to make a substantive application now?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "You told us you've used delegated functions"
