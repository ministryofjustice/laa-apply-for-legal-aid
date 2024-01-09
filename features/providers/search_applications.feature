Feature: Search applications
  @javascript @vcr
  Scenario: Going to the search page
    Given I am logged in as a provider
    And An application has been created
    Then I visit the application service
    Then I click link "Start"
    Then I choose 'London'
    Then I click 'Save and continue'
    Then I click link "Search applications"
    Then I should be on a page showing "Search applications"
