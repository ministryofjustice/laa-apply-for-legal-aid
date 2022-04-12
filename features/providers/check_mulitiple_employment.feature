Feature: check_mulitiple_employment
  @javascript @vcr
  Scenario: I am able to complete an application for an employed applicant with multiple employers
    Given I am logged in as a provider
    And csrf is enabled
    And an applicant named Ida Paisley has completed her true layer interaction
    And the system is prepped for the employed journey
    Then I visit the applications page
    Then I click link 'Ida Paisley'
    Then I should be on a page showing "Continue Ida Paisley's financial assessment"
    Then I click 'Continue'
    Then I should be on a page showing "Review Ida Paisley's employment income"
    Then I choose "Yes"
    Then I fill "legal-aid-application-extra-employment-information-details-field" with "Paisley also earns 50 gbp"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's income"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's outgoings"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client’s bank accounts"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Select if your client has received payments from these schemes or charities"
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Paisley also earns 50 gbp"
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check if Ida Paisley can get legal aid"
    Then I click "Show all sections"
    And I should be on a page showing "Employment income"
    And I should be on a page showing "Fixed employment expenses deduction"
    And I should be on a page showing "-£45"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"
    When I click link 'Latest incident details'
    Then I should be on a page showing 'Latest incident details'
    Then I fill "application_merits_task_incident_told_on_3i" with "5"
    Then I fill "application_merits_task_incident_told_on_2i" with "5"
    Then I fill "application_merits_task_incident_told_on_1i" with "21"
    Then I fill "application_merits_task_incident_occurred_on_3i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_2i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_1i" with "21"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Opponent details'
    Then I fill "application-merits-task-opponent-full-name-field" with "Bob"
    Then I choose "application-merits-task-opponent-understands-terms-of-court-order-true-field"
    Then I choose "application-merits-task-opponent-warning-letter-sent-true-field"
    Then I choose "application-merits-task-opponent-police-notified-true-field"
    Then I fill "application-merits-task-opponent-police-notified-details-true-field" with "Single employment test"
    Then I choose "application-merits-task-opponent-bail-conditions-set-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "application-merits-task-statement-of-case-statement-field" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"
    When I click link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Upload supporting evidence"
    Then I upload an evidence file named 'hello_world.pdf'
    Then I sleep for 5 seconds
    #Then I should be able to categorise 'hello_world.pdf' as 'Employment evidence'
    #Then I click 'Save and continue'