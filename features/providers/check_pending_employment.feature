Feature: Check pending employment
  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to complete an application for an employed applicant with pending HMRC request
    Given I am logged in as a provider
    And csrf is enabled
    And an applicant named John Pending has completed his true layer interaction
    And the system is prepped for the employed journey

    When I visit the applications page
    And I click link 'John Pending'
    Then I should be on a page showing "Continue John Pending's financial assessment"

    When I click 'Continue'
    Then I should be on a page showing "HMRC has no record of your client's employment in the last 3 months"

    When I fill "legal-aid-application-full-employment-details-field" with "Pending"
    And I click 'Save and continue'
    Then I should be on a page showing "Your client's income"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Your client's outgoings"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Your client’s bank accounts"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"

    When I check "None of these"
    And I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"

    When I click 'Save and continue'
    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Select if your client has received payments from these schemes or charities"

    When I check "None of these"
    And I click 'Save and continue'
    Then I should be on a page showing "Pending"

    When I click 'Save and continue'
    Then I should be on a page showing "We need to check if John Pending can get legal aid"
    When I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"

    When I click link 'Latest incident details'
    Then I should be on a page showing 'Latest incident details'

    When I fill "application_merits_task_incident_told_on_3i" with "5"
    And I fill "application_merits_task_incident_told_on_2i" with "5"
    And I fill "application_merits_task_incident_told_on_1i" with "21"
    And I fill "application_merits_task_incident_occurred_on_3i" with "4"
    And I fill "application_merits_task_incident_occurred_on_2i" with "4"
    And I fill "application_merits_task_incident_occurred_on_1i" with "21"
    And I click 'Save and continue'
    Then I should be on a page showing 'Opponent details'

    When I fill "application-merits-task-opponent-full-name-field" with "Bob"
    And I choose "application-merits-task-opponent-understands-terms-of-court-order-true-field"
    And I choose "application-merits-task-opponent-warning-letter-sent-true-field"
    And I choose "application-merits-task-opponent-police-notified-true-field"
    And I fill "application-merits-task-opponent-police-notified-details-true-field" with "Single employment test"
    And I choose "application-merits-task-opponent-bail-conditions-set-field"
    And I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"

    When I fill "application-merits-task-statement-of-case-statement-field" with "Statement of case"
    And I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"

    When I click link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"

    When I click 'Save and continue'
    Then I should be on a page showing "Upload supporting evidence"

    When I upload an evidence file named 'hello_world.pdf'
    And I sleep for 2 seconds
    Then I should be able to categorise 'hello_world.pdf' as 'Employment evidence'

    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"

    When I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"

    When I check "I confirm the above is correct and that I'll obtain a signed declaration from my client."
    And I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"

    When I click 'Submit and continue'
    Then I should be on a page showing "Application complete"

    When I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
