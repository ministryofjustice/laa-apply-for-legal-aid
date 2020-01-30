Feature: Non-passported applicant journeys
  @javascript
  Scenario: Completes the merits application for applicant that does not receive benefits
    Given I start the merits application
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Your client's income"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client tell you about the latest domestic abuse incident?'
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    Then I choose option "Respondent understands terms of court order True"
    Then I choose option "Respondent warning letter sent True"
    Then I choose option "Respondent police notified True"
    Then I choose option "Respondent bail conditions set True"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    And I should not see "Proceedings currently before court"
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "Statement" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click "Save and continue"
    Then I should be on a page showing "Declaration"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And I should not see "Passported"