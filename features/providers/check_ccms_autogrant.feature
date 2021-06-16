Feature: Checking ccms means does NOT auto grant
  @javascript @vcr
  Scenario: I am able to create a passported application with Cap Contribs > £3k and with restrictions
    Given the setting to manually review all cases is enabled
    And I have a passported application with no assets on the "savings_and_investments" page
    Then I visit the applications page
    Then I view the previously created application
    Then I click 'Save and continue'
    Then I am on the "Which types of savings or investments does your client have?" page
    And I check 'Money not in a bank account'
    Then I fill "savings-amount-cash-field" with "4000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets"
    Then I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Select if your client has received payments from these schemes or charities"
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And I should be on a page showing 'Money not in a bank account'
    And I should be on a page showing '£4,000'
    Then I click 'Save and continue'
    And I should be on a page showing "may need to pay towards legal aid"
    And I should be on a page showing "We’ve calculated that your client should pay £1,000 from their disposable capital."
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    Then I click 'Continue'
    Then I should be on a page showing 'Latest incident details'
    Then I fill "application_merits_task_incident_told_on_3i" with "5"
    Then I fill "application_merits_task_incident_told_on_2i" with "5"
    Then I fill "application_merits_task_incident_told_on_1i" with "20"
    Then I fill "application_merits_task_incident_occurred_on_3i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_2i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_1i" with "20"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Opponent details'
    Then I fill "application-merits-task-opponent-full-name-field" with "Bob"
    Then I choose "application-merits-task-opponent-understands-terms-of-court-order-true-field"
    Then I choose "application-merits-task-opponent-warning-letter-sent-true-field"
    Then I choose "application-merits-task-opponent-police-notified-true-field"
    Then I fill "application-merits-task-opponent-police-notified-details-true-field" with "Mike test"
    Then I choose "application-merits-task-opponent-bail-conditions-set-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "application-merits-task-statement-of-case-statement-field" with "Mike SOC"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "proceeding-merits-task-chances-of-success-success-likely-true-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers and submit application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then the application must be manually reviewed in CCMS

@javascript @vcr
  Scenario: I am able to create a passported application without Cap Contribs and with no restrictions
    Given the setting to manually review all cases is enabled
    And I have a passported application with no assets on the "savings_and_investments" page
    Then I visit the applications page
    Then I view the previously created application
    Then I click 'Save and continue'
    Then I am on the "Which types of savings or investments does your client have?" page
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I am on the "Which types of assets does your client have?" page
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I am on the "Select if your client has received payments from these schemes or charities" page
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I am on the "Check your answers" page
    Then I click 'Save and continue'
    And I should be on a page showing "could be eligible for legal aid"
    And I should be on a page showing "Based on their financial situation, your client may not have to pay towards legal aid."
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    Then I click 'Continue'
    Then I should be on a page showing 'Latest incident details'
    Then I fill "application_merits_task_incident_told_on_3i" with "5"
    Then I fill "application_merits_task_incident_told_on_2i" with "5"
    Then I fill "application_merits_task_incident_told_on_1i" with "20"
    Then I fill "application_merits_task_incident_occurred_on_3i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_2i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_1i" with "20"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Opponent details'
    Then I fill "application-merits-task-opponent-full-name-field" with "Bob"
    Then I choose "application-merits-task-opponent-understands-terms-of-court-order-true-field"
    Then I choose "application-merits-task-opponent-warning-letter-sent-true-field"
    Then I choose "application-merits-task-opponent-police-notified-true-field"
    Then I fill "application-merits-task-opponent-police-notified-details-true-field" with "Mike test"
    Then I choose "application-merits-task-opponent-bail-conditions-set-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "application-merits-task-statement-of-case-statement-field" with "Mike SOC"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "proceeding-merits-task-chances-of-success-success-likely-true-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers and submit application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then the application should be auto granted in CCMS