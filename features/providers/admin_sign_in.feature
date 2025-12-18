@stub_bank_holidays
Feature: Admin sign in

  @javascript @mock_admin_auth_enabled @vcr_turned_off
  Scenario: I am able to sign in when mock auth is enabled
    Given there is an admin user
    When I visit the admin page
    Then I should see "Admin: Sign In"

    When I fill 'email' with 'test@test.com'
    And I fill 'password' with 'wrong password'
    And I click "Sign in"
    Then I should be on a page with title "Admin: Sign In"
    And I should see "Invalid email or password."

    When I fill in the mock admin email and password
    And I click "Sign in"
    Then I should be on a page with title "Admin: Legal Aid Applications"
    And I should see "Signed in successfully."

    When I click link 'Admin sign out'
    Then I should be on a page with title "Apply for civil legal aid"
    And I should see "You have been signed out."
