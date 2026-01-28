Feature: Sign in

  @javascript @mock_auth_enabled @vcr_turned_off @stub_bank_holidays
  Scenario: I am able to sign in and select an office when mock auth is enabled
    When I visit the root page
    Then I should see "Providers can use this service to apply for civil legal aid for their clients"

    When I click govuk-button "Sign in"
    Then I should be on a page with title "Sign in"

    When I fill 'email' with 'test@test.com'
    And I fill 'password' with 'wrong password'
    And I click "Sign in"
    Then I should be on a page with title "Sign in"
    And I should see "Invalid email or password"

    When I fill in the mock user email and password
    And I click "Sign in"
    Then I should be on a page with title "Select the account number of the office handling this application"
    And I should see "Signed in successfully"

    When I choose '0X395U'
    And I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

    When I click link 'Sign out'
    Then I should be on a page with title "Help us improve the Apply for civil legal aid service"
    And I should see "You have been signed out"

  @javascript @mock_auth_enabled_on_production
  Scenario: I am unable to use mock user login on the production environment even when it is enabled
    When I visit the root page
    Then I should see "Providers can use this service to apply for civil legal aid for their clients"

    When I click govuk-button "Sign in"
    Then I should be on a page with title "Select the account number of the office handling this application"
    And I should see "Signed in successfully"
