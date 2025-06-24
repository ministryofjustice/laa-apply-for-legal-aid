@javascript @vcr
Feature: Application task list client and case details section

  Background:
    Given I am logged in as a provider
    When I visit the application service
    And I click link "Sign in"
    Then I choose "London"
    Then I click "Save and continue"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'

    When I click 'Agree and continue'
    Then I should be on the Applicant page

  Scenario: I can view the task list's client and case details information
    When I enter name 'Test', 'User'
    And I choose 'No'
    And I enter a date of birth that will make me 18 today
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have a National Insurance number?"

    When I go to the application task list
    Then the "Client and case details" task list section should contain:
      | name | link_enabled | status |
      | Client details | true | In progress |

    When I click link "Client details"
    Then I should be on a page showing "Enter your client's details"

    When I click "Save and continue"
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'

    When I click "Save and continue"
    Then I should be on a page showing "Has your client applied for civil legal aid before?"
    And I choose "No"

    When I click "Save and continue"
    Then I should be on a page showing "Where should we send your client's correspondence?"
    And I choose "My client's UK home address"

    When I click "Save and continue"
    Then I am on the postcode entry page
    And I enter a postcode "SW1H 9EA"
    And I click find address
    And I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'

    When I click "Use this address"
    Then I should be on a page showing "What does your client want legal aid for?"

    When I go to the application task list
    Then the "Client and case details" task list section should contain:
      | name | link_enabled | status |
      | Client details | false | Completed |
