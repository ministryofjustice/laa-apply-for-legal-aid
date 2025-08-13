Feature: Search applications
  @javascript @vcr @stub_office_schedules_and_user
  Scenario: Going to the search page
    Given I am logged in as a provider
    And An application has been created
    Then I visit the application service
    Then I click link "Start"
    Then I choose '0X395U'
    Then I click 'Save and continue'
    Then I click link 'Search'
    Then I should be on a page showing "Search applications"
