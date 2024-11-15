Feature: Check pending employment
  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to complete an application for an employed applicant with pending HMRC request
    Given I am logged in as a provider
    And the feature flag for collect_hmrc_data is enabled
    And csrf is enabled
    And an applicant named John Pending has completed his true layer interaction

    When I visit the in progress applications page
    And I click link 'John Pending'
    Then I should be on a page showing "Continue John Pending's financial assessment"

    When I click 'Continue'
    Then I should be on a page showing "HMRC has no record of your client's employment in the last 3 months"

    When I fill "legal-aid-application-full-employment-details-field" with "Pending"
    And I click 'Save and continue'
    Then I should be on a page showing "Which of these payments does your client get?"
    When I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"

    When I select "My client receives none of these payments in cash"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client get student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"

    When I select 'Childcare'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client pays in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page showing "Sort your client's income into categories"

    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'
    Then I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select childcare payments'
    When I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    Then I should be on a page showing "Pending"

    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"

    When I click 'Continue'
    Then I should be on a page showing "Does your client own the home that they live in?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"

    When I choose "No"
    And I click 'Save and continue'

    Then I should be on a page showing "Your client's bank accounts"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"

    When I check "None of these savings or investments"
    And I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"

    When I click 'Save and continue'
    Then I should be on a page showing "Is your client banned from selling or borrowing against their assets?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Which schemes or trusts have paid your client?"

    When I check "None of these schemes or trusts"
    And I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'

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

    # already an opponent added by the setup
    Then I should be on a page showing "You have added 1 opponent"
    When I choose "No"
    And I click 'Save and continue'

    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'

    Then I should be on a page showing "Domestic abuse summary"
    And I choose "application-merits-task-domestic-abuse-summary-warning-letter-sent-true-field"
    And I choose "application-merits-task-domestic-abuse-summary-police-notified-true-field"
    And I fill "application-merits-task-domestic-abuse-summary-police-notified-details-true-field" with "Single employment test"
    And I choose "application-merits-task-domestic-abuse-summary-bail-conditions-set-field"
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
    And I select a category of "Client's employment evidence" for the file "hello_world.pdf"

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
