Feature: Cookies
  @javascript
  Scenario: I am able to update my cookie preferences via the cookies page
    Given I complete the journey as far as check your answers
    And I click link 'Cookies'
    Then I should be on a page showing 'Cookies on Apply for Legal Aid'
    When I click 'Save changes'
    Then I should be on a page showing 'Select if you would like to enable cookies'
    When I choose 'Use this cookie to measure my website use'
    And I click 'Save changes'
    Then I should be on a page showing 'Your cookie settings were saved'
    When I click link 'Go back to the page you were looking at'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I am able to update my cookie preferences via the cookies banner
    Given I am logged in as a provider
    And I have not yet updated my cookie preferences
    Given I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    And I click link "Apply for legal aid"
    Then I am on the legal aid applications
    Then I should see 'Cookies on Apply for Legal Aid'
    When I click 'Accept analytics cookies'
    Then I should see "You've accepted analytics cookies."
    When I click 'Hide'
    Then I should not see '"You've accepted analytics cookies."
