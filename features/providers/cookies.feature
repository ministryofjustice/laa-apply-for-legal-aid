@javascript
Feature: Cookies
  Scenario: I am able to update my cookie preferences via the cookies page
    Given I complete the journey as far as check your answers
    And I click link 'Cookies'
    # Then I should be on a page with title 'Cookies on Apply for legal aid'
    Then I should be on a page with title 'No a real page'

    When I click 'Save changes'
    Then I should be on a page showing 'Select if you would like to enable cookies'

    When I choose 'Use this cookie to measure my website use'
    And I click 'Save changes'
    Then I should be on a page showing 'Your cookie settings were saved'

    When I click link 'Go back to the page you were looking at'
    Then I should be on a page showing 'Check your answers'

  Scenario: I am able to update my cookie preferences via the cookies banner and Hide the notice
    Given I start the journey without cookie preferences

    When I click link 'Accept analytics cookies'
    Then I should see "You've accepted analytics cookies."

    When I click link 'Hide'
    Then I should not see "You've accepted analytics cookies."

  Scenario: I am able to view the cookies page from the cookies banner and save changes
    Given I start the journey without cookie preferences

    When I click link 'View cookies'
    Then I should be on a page with title 'Cookies on Apply for legal aid'

    When I choose 'Use this cookie to measure my website use'
    And I click 'Save changes'
    Then I should be on a page showing 'Your cookie settings were saved'

  Scenario: I am able to Accept analytics cookie and then change my cookie preferences via the cookies banner
    Given I start the journey without cookie preferences

    When I click link 'Accept analytics cookies'
    Then I should see "You've accepted analytics cookies."
    And I should see "You can change your cookie settings at any time"

    When I click link "change your cookie settings"
    Then I should be on a page with title 'Cookies on Apply for legal aid'

  Scenario: I am able to Reject analytics cookie and then change my cookie preferences via the cookies banner
    Given I start the journey without cookie preferences

    When I click link 'Reject analytics cookies'
    Then I should see "You've rejected analytics cookies."
    And I should see "You can change your cookie settings at any time"

    When I click link "change your cookie settings"
    Then I should be on a page with title 'Cookies on Apply for legal aid'

  Scenario: I am able to return to my legal aid applications
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Sign in"
    Then I choose 'London'
    Then I click 'Save and continue'

    And I click link "Make a new application"
    And I click link "Accept analytics cookies"

    # required for test to pass locally with chrome headless
    Then I temporarily resize browser window to width 1600 height 1000 and click "Apply for legal aid"

    Then I am on the legal aid applications page

  Scenario: I am prompted to update my cookie preferences via the cookies banner if they have expired
    Given I start the journey with expired cookie preferences

    When I click link 'Accept analytics cookies'
    Then I should see "You've accepted analytics cookies."

    When I click link 'Hide'
    Then I should not see "You've accepted analytics cookies."
