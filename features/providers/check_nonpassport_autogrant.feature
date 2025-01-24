Feature: Checking ccms means does NOT auto grant for non passported applications
  @javascript @vcr
  Scenario: I am able to create a non passported application with cap Contribs > £3k and without restrictions
    Given The means questions have been answered by the applicant
    And Bank transactions exist
    Then I should be on a page showing 'Your client has shared their financial information'
    Then I click 'Continue'

    Then I should be on the 'identify_types_of_income' page showing "Which of these payments does your client get?"
    Then I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client gets in cash"
    When I select "My client gets none of these payments in cash"
    And I click 'Save and continue'

    Then I should be on a page showing "Does your client get student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"
    Then I select "Childcare"
    And I click 'Save and continue'
    Then I should be on the 'cash_outgoing' page showing "Select payments your client pays in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'
    When I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select childcare payments'
    When I select the first checkbox
    And I click 'Save and continue'
    Then I click 'Save and continue'

    When I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"

    Then I choose "legal-aid-application-has-dependants-field"
    Then I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"
    When I click "Continue"
    Then I am on the "Does your client own the home they usually live in?" page
    Then I choose "legal-aid-application-own-home-no-field"
    Then I click 'Save and continue'
    Then I am on the "Does your client own a vehicle?" page
    Then I choose "legal-aid-application-own-vehicle-field"
    Then I click 'Save and continue'
    Then I am on the "Your client's bank accounts" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I am on the "Which savings or investments does your client have?" page
    And I check "savings-amount-check-box-cash-true-field"
    Then I fill "savings-amount-cash-field" with "4000"
    Then I click 'Save and continue'
    Then I am on the "Which assets does your client have?" page
    Then I check "other-assets-declaration-none-selected-true-field"
    Then I click 'Save and continue'
    Then I am on the "Is your client banned from selling or borrowing against their assets?" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Disregarded payments"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"
    When I check "My client has not received any of these payments"
    Then I click 'Save and continue'
    Then I am on the "Check your answers" page
    Then I click 'Save and continue'
    Then I am on the "may need to pay towards legal aid" page
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'Latest incident details'
    Then I fill "application_merits_task_incident_told_on_3i" with "5"
    Then I fill "application_merits_task_incident_told_on_2i" with "5"
    Then I fill "application_merits_task_incident_told_on_1i" with "20"
    Then I fill "application_merits_task_incident_occurred_on_3i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_2i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_1i" with "20"
    When I click 'Save and continue'
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
    Then I fill "application-merits-task-domestic-abuse-summary-police-notified-details-true-field" with "Mike non passported test"
    Then I choose "application-merits-task-domestic-abuse-summary-bail-conditions-set-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "application-merits-task-statement-of-case-statement-field" with "Mike non passported SOC"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    When I click the first link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "proceeding-merits-task-chances-of-success-success-likely-true-field"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    When I click the last link 'Chances of success'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 50% or better?'
    When I choose 'Yes'
    And I click 'Save and continue'
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
  Scenario: I am able to create a non passported application without Income or Cap Contribs and with no restrictions
    Given The means questions have been answered by the applicant
    And Bank transactions exist
    Then I should be on a page showing 'Your client has shared their financial information'
    Then I click 'Continue'

    Then I should be on the 'identify_types_of_income' page showing "Which of these payments does your client get?"
    Then I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client gets in cash"
    When I select "My client gets none of these payments in cash"
    And I click 'Save and continue'

    Then I should be on a page showing "Does your client get student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"
    Then I select "Childcare"
    And I click 'Save and continue'
    Then I should be on the 'cash_outgoing' page showing "Select payments your client pays in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'
    When I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select childcare payments'
    When I select the first checkbox
    And I click 'Save and continue'
    Then I click 'Save and continue'
    When I click 'Save and continue'

    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"
    Then I click 'Continue'
    Then I am on the "Does your client own the home they usually live in?" page
    Then I choose "legal-aid-application-own-home-no-field"
    Then I click 'Save and continue'
    Then I am on the "Does your client own a vehicle?" page
    Then I choose "legal-aid-application-own-vehicle-field"
    Then I click 'Save and continue'
    Then I am on the "Your client's bank accounts" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I am on the "Which savings or investments does your client have?" page
    And I check "savings-amount-check-box-cash-true-field"
    Then I fill "savings-amount-cash-field" with "1000"
    Then I click 'Save and continue'
    Then I am on the "Which assets does your client have?" page
    Then I check "other-assets-declaration-none-selected-true-field"
    Then I click 'Save and continue'
    Then I am on the "Is your client banned from selling or borrowing against their assets?" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Disregarded payments"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I am on the "Check your answers" page
    Then I click 'Save and continue'
    Then I am on the "may need to pay towards legal aid" page
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'Latest incident details'
    Then I fill "application_merits_task_incident_told_on_3i" with "5"
    Then I fill "application_merits_task_incident_told_on_2i" with "5"
    Then I fill "application_merits_task_incident_told_on_1i" with "20"
    Then I fill "application_merits_task_incident_occurred_on_3i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_2i" with "4"
    Then I fill "application_merits_task_incident_occurred_on_1i" with "20"
    When I click 'Save and continue'
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
    Then I fill "application-merits-task-domestic-abuse-summary-police-notified-details-true-field" with "Mike non passported test"
    Then I choose "application-merits-task-domestic-abuse-summary-bail-conditions-set-field"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "application-merits-task-statement-of-case-statement-field" with "Mike non passported SOC"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    When I click the first link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "proceeding-merits-task-chances-of-success-success-likely-true-field"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    When I click the last link 'Chances of success'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 50% or better?'
    When I choose 'Yes'
    And I click 'Save and continue'
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
