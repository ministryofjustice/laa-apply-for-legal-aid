Feature: Provider feedback
  @javascript @vcr
  Scenario: Enter feedback within provider journey
    Given I start the journey as far as the applicant page
    Then I click link "feedback"
    Then I should be on a page showing "Help us improve this service"
    Then I choose govuk radio "Yes" for "Were you able to do what you needed today?"
    Then I choose govuk radio "Easy" for "How easy or difficult was it to use this service?"
    Then I choose govuk radio "Satisfied" for "Overall, how satisfied were you with this service?"
    Then I fill "improvement suggestion" with "Foo bar"
    Then I click "Send"
    Then I should be on a page showing "Thank you for your feedback"
    Then I click link "Back to your application"
    Then I should be on the Applicant page
