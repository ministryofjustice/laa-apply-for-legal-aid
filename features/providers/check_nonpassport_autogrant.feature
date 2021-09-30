Feature: Checking ccms means does NOT auto grant for non passported applications
  @javascript @vcr
  Scenario: I am able to create a non passported application with cap Contribs > £3k and without restrictions
    Given The means questions have been answered by the applicant
    And Bank transactions exist
    Then I should be on a page showing 'Continue your application'
    Then I click 'Continue'
    Then I am on the "Your client's income" page
    Then I choose "binary-choice-form-no-income-summaries-true-field"
    Then I click 'Save and continue'
    Then I am on the "Does your client have any dependants?" page
    Then I choose "legal-aid-application-has-dependants-field"
    Then I click 'Save and continue'
    Then I am on the "Your client's outgoings" page
    Then I choose "binary-choice-form-no-outgoings-summaries-true-field"
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
    Then I am on the "Which types of savings or investments does your client have?" page
    And I check "savings-amount-check-box-cash-true-field"
    Then I fill "savings-amount-cash-field" with "4000"
    Then I click 'Save and continue'
    Then I am on the "Which types of assets does your client have?" page
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
    Then I should be on a page showing 'Opponent details'
    Then I fill "application-merits-task-opponent-full-name-field" with "Bob"
    Then I choose "application-merits-task-opponent-understands-terms-of-court-order-true-field"
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
    Then I click 'Continue'
    Then I should be on the 'gateway_evidence' page showing 'Upload supporting evidence'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers and submit application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then the application must be manually reviewed in CCMS

@javascript @vcr
  Scenario: I am able to create a non passported application without Income or Cap Contribs and with no restrictions
    And The means questions have been answered by the applicant
    And Bank transactions exist
    Then I should be on a page showing 'Continue your application'
    Then I click 'Continue'
    Then I am on the "Your client's income" page
    Then I choose "binary-choice-form-no-income-summaries-true-field"
    Then I click 'Save and continue'
    Then I am on the "Does your client have any dependants?" page
    Then I choose "legal-aid-application-has-dependants-field"
    Then I click 'Save and continue'
    Then I am on the "Your client's outgoings" page
    Then I choose "binary-choice-form-no-outgoings-summaries-true-field"
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
    Then I am on the "Which types of savings or investments does your client have?" page
    And I check "savings-amount-check-box-cash-true-field"
    Then I fill "savings-amount-cash-field" with "1000"
    Then I click 'Save and continue'
    Then I am on the "Which types of assets does your client have?" page
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
    Then I should be on a page showing 'Opponent details'
    Then I fill "application-merits-task-opponent-full-name-field" with "Bob"
    Then I choose "application-merits-task-opponent-understands-terms-of-court-order-true-field"
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
    Then I click 'Continue'
    Then I should be on the 'gateway_evidence' page showing 'Upload supporting evidence'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers and submit application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then the application must be manually reviewed in CCMS