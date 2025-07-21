Feature: Mock auth for provider login
  @javascript
  Scenario: A provider can login with mock auth data from the start page
    Given the provider account has been created
    And I visit the root page
    And I click link 'start'
    Then I should be on a page with title "Select the account number of the office handling this application"
