Feature: Provider feedback
  @javascript @vcr @disable-rack-attack
  Scenario: Enter the minimum feedback required within provider journey
    Given I start the journey as far as the applicant page
    When I click link "feedback"
    Then I should be on a page with title "Help us improve the Apply for legal aid service"
    And I should be on a page showing "If you have problems using this service, email apply-for-civil-legal-aid@digital.justice.gov.uk to get help."
    And I should be on a page showing "Help us improve the Apply for legal aid service"
    And I should be on a page showing "We’ll use your answers to help improve the service"
    And I should see a link with text "See how we protect your personal information"

    And I should be on a page showing "1. Were you able to do what you needed today?"
    And I should be on a page showing "2. How easy or difficult was it to use this service?"
    And I should be on a page showing "3. What do you think about the amount of time it took you to use this service?"
    And I should be on a page showing "4. Overall, how satisfied were you with this service?"
    And I should be on a page showing "5. Do you have any feedback or suggestions on how we could improve the service?"
    And I should be on a page showing "6. If you're happy to be contacted for research opportunities with the Legal Aid Agency (LAA), please provide your contact details"

    # Test the mandatory field errors
    When I click "Send"
    Then I should see govuk error summary "Select yes if you were you able to do what you needed today"
    And I should see govuk error summary "Select how satisfied you were with the service"
    And I should see govuk error summary "Select how easy or difficult it was to apply for legal aid using the new service"

    When I choose "Yes"
    And I choose "Easy"
    And I choose "Satisfied"
    And I click "Send"
    Then I should be on a page with title "Thank you for your feedback"

    When I click link "Back to your application"
    Then I should be on the Applicant page

  @javascript @vcr @disable-rack-attack
  Scenario: Enter all feedback possible within provider journey
    Given I start the journey as far as the applicant page
    When I click link "feedback"
    Then I should be on a page with title "Help us improve the Apply for legal aid service"

    When I choose "No"
    And I fill "feedback-done-all-needed-reason-field" with "could not complete..."
    And I choose "Very difficult"
    And I fill "feedback-difficulty-reason-field" with "having reall difficulty..."
    And I choose "It was a great deal of time"
    And I fill "feedback-time-taken-satisfaction-reason-field" with "Took me ages..."
    And I choose "Very dissatisfied"
    And I fill "feedback-satisfaction-reason-field" with "Very unhappy..."
    And I fill "feedback-improvement-suggestion-field" with "Hera are some suggestions..."

    # Test the interdependent field errors
    And I fill "Name" with "Joe Bloggs"
    When I click "Send"
    Then I should see govuk error summary "Enter a contact name and email or neither"

    # Test the valid email format
    When I fill "Email" with "JoeBloggs"
    And I click "Send"
    Then I should see govuk error summary "Enter a valid email address"

    When I fill "Email" with "Joe@Bloggs"
    And I click "Send"
    Then I should be on a page with title "Thank you for your feedback"

    When I click link "Back to your application"
    Then I should be on the Applicant page

  @javascript @vcr @disable-rack-attack
  Scenario: Enter the minimum feedback from provider signout journey
    Given I start the journey as far as the applicant page
    When I click link "Sign out"
    Then I should be on a page with title "Help us improve the Apply for legal aid service"
    Then I should be on a page showing "You have been signed out"

    # This is just to that test error page rerender does not muck up later back page functionality
    When I click "Send"
    Then I should see govuk error summary "Select yes if you were you able to do what you needed today"

    When I choose "Yes"
    And I choose "Easy"
    And I choose "Satisfied"
    And I click "Send"
    Then I should be on a page with title "Thank you for your feedback"

    When I click link "Back to your application"
    Then I should be on a page with title "Sign in - Apply for legal aid"
