Feature: Check single employment
  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to complete an application for an employed applicant with a single employer
    Given I am logged in as a provider
    And csrf is enabled
    And an applicant named Langley Yorke has completed his true layer interaction

    When I visit the applications page
    And I click link 'Langley Yorke'
    Then I should be on a page showing "Continue Langley Yorke's financial assessment"

    When I click 'Continue'
    Then I should be on a page showing "Review Langley Yorke's employment income"

    When I choose "Yes"
    And I fill "legal-aid-application-extra-employment-information-details-field" with "Yorke also earns 50 gbp"
    And I click 'Save and continue'

    Then I should be on a page showing "Which payments does your client receive?"
    When I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client receive student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"

    When I select 'Housing'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client makes in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page showing "Sort your client's income into categories"

    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select any benefits your client got in the last 3 months'
    Then I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select housing payments'
    When I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

    When I click 'Save and continue'
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

    When I check "My client has none of these savings or investments"
    And I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"

    When I click 'Save and continue'
    Then I should be on a page showing "Is there anything else you need to tell us about your client’s assets?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Select if your client has received payments from these schemes or charities"

    When I check "My client has received none of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"

    When I click 'Save and continue'
    Then I should be on a page showing "We need to check if Langley Yorke can get legal aid"

    When I click "Show all sections"
    Then I should be on a page showing "Employment income"
    And I should be on a page showing "Fixed employment expenses deduction"
    And I should be on a page showing "-£45"
    And I click 'Save and continue'
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
    Then I should be on a page showing "Opponent's name"
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
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
    And I should be able to categorise 'hello_world.pdf' as 'Employment evidence'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"

    When I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"

    When I check "I confirm the above is correct and that I'll get a signed declaration from my client"
    And I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"

    When I click 'Submit and continue'
    Then I should be on a page showing "Application complete"

    When I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
