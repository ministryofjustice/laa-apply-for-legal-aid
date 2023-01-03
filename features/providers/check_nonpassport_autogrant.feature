Feature: Checking ccms means does NOT auto grant for non passported applications
  @javascript @vcr
  Scenario: I am able to create a non passported application with cap Contribs > £3k and without restrictions
    Given The means questions have been answered by the applicant
    And Bank transactions exist
    Then I should be on a page showing 'Your client has shared their financial information'
    Then I click 'Continue'

    Then I should be on the 'identify_types_of_income' page showing "Which payments does your client receive?"
    Then I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"
    When I select "None of the above"
    And I click 'Save and continue'

    Then I should be on a page showing "Does your client receive student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"
    Then I select "Childcare"
    And I click 'Save and continue'
    Then I should be on the 'cash_outgoing' page showing "Select payments your client makes in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select benefits payments'
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
    Then I am on the "Does your client own the home that they live in?" page
    Then I choose "legal-aid-application-own-home-no-field"
    Then I click 'Save and continue'
    Then I am on the "Does your client own a vehicle?" page
    Then I choose "legal-aid-application-own-vehicle-field"
    Then I click 'Save and continue'
    Then I am on the "Your client’s bank accounts" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I am on the "Which savings or investments does your client have?" page
    And I check "savings-amount-check-box-cash-true-field"
    Then I fill "savings-amount-cash-field" with "4000"
    Then I click 'Save and continue'
    Then I am on the "Which assets does your client have?" page
    Then I check "other-assets-declaration-none-selected-true-field"
    Then I click 'Save and continue'
    Then I am on the "Is your client prohibited from selling or borrowing against their assets?" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I am on the "Select if your client has received payments from these schemes or charities" page
    Then I check "policy-disregards-none-selected-true-field"
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
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent's name"
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    Then I choose "application-merits-task-opponent-warning-letter-sent-true-field"
    Then I choose "application-merits-task-opponent-police-notified-true-field"
    Then I fill "application-merits-task-opponent-police-notified-details-true-field" with "Mike non passported test"
    Then I choose "application-merits-task-opponent-bail-conditions-set-field"
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
    Then I select the first checkbox
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

    Then I should be on the 'identify_types_of_income' page showing "Which payments does your client receive?"
    Then I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"
    When I select "None of the above"
    And I click 'Save and continue'

    Then I should be on a page showing "Does your client receive student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"
    Then I select "Childcare"
    And I click 'Save and continue'
    Then I should be on the 'cash_outgoing' page showing "Select payments your client makes in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select benefits payments'
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
    Then I am on the "Does your client own the home that they live in?" page
    Then I choose "legal-aid-application-own-home-no-field"
    Then I click 'Save and continue'
    Then I am on the "Does your client own a vehicle?" page
    Then I choose "legal-aid-application-own-vehicle-field"
    Then I click 'Save and continue'
    Then I am on the "Your client’s bank accounts" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I am on the "Which savings or investments does your client have?" page
    And I check "savings-amount-check-box-cash-true-field"
    Then I fill "savings-amount-cash-field" with "1000"
    Then I click 'Save and continue'
    Then I am on the "Which assets does your client have?" page
    Then I check "other-assets-declaration-none-selected-true-field"
    Then I click 'Save and continue'
    Then I am on the "Is your client prohibited from selling or borrowing against their assets?" page
    Then I choose "No"
    Then I click 'Save and continue'
    Then I am on the "Select if your client has received payments from these schemes or charities" page
    Then I check "policy-disregards-none-selected-true-field"
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
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent's name"
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    Then I choose "application-merits-task-opponent-warning-letter-sent-true-field"
    Then I choose "application-merits-task-opponent-police-notified-true-field"
    Then I fill "application-merits-task-opponent-police-notified-details-true-field" with "Mike non passported test"
    Then I choose "application-merits-task-opponent-bail-conditions-set-field"
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
    Then I select the first checkbox
    Then I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then the application must be manually reviewed in CCMS
