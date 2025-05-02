Feature: Checking ccms means does NOT auto grant
  @javascript @vcr
  Scenario: I am able to create a passported application with Cap Contribs > £3k and with restrictions
    Given the setting to manually review all cases is enabled
    And I have a passported application with no assets on the "savings_and_investments" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I click 'Save and continue'
    Then I am on the "Which savings or investments does your client have?" page
    And I check 'Money not in a bank account'
    Then I fill "savings-amount-cash-field" with "4000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    Then I check "None of these assets"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client banned from selling or borrowing against their assets?"
    Then I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Disregarded payments"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And I should be on a page showing 'Money not in a bank account'
    And I should be on a page showing '£4,000'
    Then I click 'Save and continue'
    And I should be on a page showing "may need to pay towards legal aid"
    And I should be on a page showing "We've calculated that your client should pay £1,000 from their disposable capital."
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Latest incident details Not started'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'Latest incident details'
    Then I fill "application_merits_task_incident_told_on_3i" with "5"
    Then I fill "application_merits_task_incident_told_on_2i" with "5"
    Then I fill "application_merits_task_incident_told_on_1i" with "20"
    Then I fill "application_merits_task_incident_occurred_on_3i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_2i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_1i" with "20"
    Then I click 'Save and continue'
    Then  I should be on a page with title "Is the opponent an individual or an organisation?"
    And I choose a 'An individual' radio button
    When I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    When I fill "First Name" with "John"
    Then I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page with title "You have added 1 opponent"
    And I should be on a page showing "Do you need to add another opponent?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    And I choose option "application-merits-task-domestic-abuse-summary-warning-letter-sent-true-field"
    Then I choose "application-merits-task-domestic-abuse-summary-warning-letter-sent-true-field"
    Then I choose "application-merits-task-domestic-abuse-summary-police-notified-true-field"
    Then I fill "application-merits-task-domestic-abuse-summary-police-notified-details-true-field" with "Mike test"
    Then I choose "application-merits-task-domestic-abuse-summary-bail-conditions-set-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Statement of case"
    When I select "Type a statement"
    Then I fill "application-merits-task-statement-of-case-statement-field" with "Mike SOC"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Not started'
    When I click link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 45% or better?"
    Then I choose "proceeding-merits-task-chances-of-success-success-likely-true-field"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Completed'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"
    Then I check "I confirm the above is correct and that I'll get a signed declaration from my client"
    Then I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then the application must be manually reviewed in CCMS

@javascript @vcr
  Scenario: I am able to create a passported application without Cap Contribs and with no restrictions
    Given the setting to manually review all cases is enabled
    And I have a passported application with no assets on the "savings_and_investments" page
    Then I visit the in progress applications page
    Then I view the previously created application
    Then I click 'Save and continue'
    Then I am on the "Which savings or investments does your client have?" page
    Then I check "None of these savings or investments"
    Then I click 'Save and continue'
    Then I am on the "Which assets does your client have?" page
    Then I check "None of these assets"
    Then I click 'Save and continue'
    Then I should be on a page showing "Disregarded payments"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I am on the "Check your answers" page
    Then I click 'Save and continue'
    And I should be on a page showing "could be eligible for legal aid"
    And I should be on a page showing "Based on their financial situation, your client may not have to pay towards legal aid."
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Latest incident details Not started'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'Latest incident details'
    Then I fill "application_merits_task_incident_told_on_3i" with "5"
    Then I fill "application_merits_task_incident_told_on_2i" with "5"
    Then I fill "application_merits_task_incident_told_on_1i" with "20"
    Then I fill "application_merits_task_incident_occurred_on_3i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_2i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_1i" with "20"
    Then I click 'Save and continue'
    Then  I should be on a page with title "Is the opponent an individual or an organisation?"
    And I choose a 'An individual' radio button
    When I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    When I fill "First Name" with "John"
    Then I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page with title "You have added 1 opponent"
    And I should be on a page showing "Do you need to add another opponent?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    Then I choose "application-merits-task-domestic-abuse-summary-warning-letter-sent-true-field"
    Then I choose "application-merits-task-domestic-abuse-summary-police-notified-true-field"
    Then I fill "application-merits-task-domestic-abuse-summary-police-notified-details-true-field" with "Mike test"
    Then I choose "application-merits-task-domestic-abuse-summary-bail-conditions-set-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Statement of case"
    When I select "Type a statement"
    Then I fill "application-merits-task-statement-of-case-statement-field" with "Mike SOC"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Not started'
    When I click link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 45% or better?"
    Then I choose "proceeding-merits-task-chances-of-success-success-likely-true-field"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Completed'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"
    Then I check "I confirm the above is correct and that I'll get a signed declaration from my client"
    Then I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then the application should be auto granted in CCMS
