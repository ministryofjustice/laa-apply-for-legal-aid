Feature: Admin application functions

  @javascript
  Scenario: I can view the ccms data from a submitted application
    Given an application has been submitted
    When I am logged in as an admin
    And I click link 'Submission details'
    Then I should see 'Legal Aid Application'
    And I should see 'CCMS Submission'
    And I should see 'Download means report'
    And I should see 'Download merits report'
    # test clicking the links with caution... it will download a file to your machine on each run

  @javascript
  Scenario: I can search for specific applications
    Given multiple applications have been submitted
    When I am logged in as an admin
    Then I should see 'Application search:'
    And I should not see the first application
    When I click 'Search'
    # without entering a value
    Then I should see 'There is a problem'
    And I should see 'Please enter a search criteria'
    When I search for the first application_ref
    And I click 'Search'
    Then I should see the first application
    And I should see 'Showing 1 of 1 result'
    When I search for the second applications client
    And I click 'Search'
    Then I should see the second application
    And I should see 'Showing 1 of 1 result'
    When I search for the third case_ccms_reference
    And I click 'Search'
    Then I should see the third application
    And I should see 'Showing 1 of 1 result'
    When I search for the fourth id
    And I click 'Search'
    Then I should see the fourth application
    And I should see 'Showing 1 of 1 result'

