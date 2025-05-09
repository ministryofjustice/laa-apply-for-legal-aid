
Feature: Start page

  @javascript
  Scenario: I am able to start the service with all flags enabled
    Given I am logged in as a provider
    And the feature flag for collect_hmrc_data is enabled
    And the feature flag for linked_applications is enabled

    When I visit the application service
    Then I should be on a page with title "Apply for civil legal aid - GOV.UK"
    And I should see "Providers can use this service to apply for civil legal aid for their clients"
    And I should see "You can use it for:"
    And I should see "domestic abuse, except DAPO \(domestic abuse protection orders\)"
    And I should see "section 8"
    And I should see "special children act"
    And I should see "public law family"

    When I click link "Sign in"
    Then I should be on a page with title "Select the account number"
