Feature: Provider feedback
  @javascript @vcr
  Scenario: Enter feedback within provider journey
    Given I start the journey as far as the applicant page
    Then I click link "feedback"
    Then I should be on a page showing "Help us improve this service"
    Then I fill "improvement suggestion" with "Foo bar"
    Then I should be on a page showing "How easy or difficult was it to use this service?"
    Then I choose "Yes"
    Then I should be on a page showing "Were you able to do what you needed today?"
    Then I choose "Easy"
    Then I choose "Satisfied"
    Then I click "Send"
    Then I should be on a page showing "Thank you for your feedback"
    Then I click link "Back to your application"
    Then I should be on the Applicant page
