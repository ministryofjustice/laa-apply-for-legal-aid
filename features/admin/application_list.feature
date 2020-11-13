Feature: Admin application functions

  @javascript
  Scenario: I can view the ccms data from a submitted application
    Given an application has been submitted
    When I am logged in as an admin
    And I click link 'Submission details'
    Then I should see 'Legal Aid Application'
    And I should see 'CCMS Submission'
