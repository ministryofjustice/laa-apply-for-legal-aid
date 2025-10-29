Feature: Check single employment
  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to complete an application for an employed applicant with a single employer
    Given I am logged in as a provider
    And csrf is enabled
    And an applicant named Langley Yorke has completed his true layer interaction

    When I visit the in progress applications page
    And I click link 'Langley Yorke'
    Then I should be on a page showing "Continue Langley Yorke's financial assessment"

    When I click 'Continue'
    Then I should be on a page showing "Review Langley Yorke's employment income"

    When I choose "Yes"
    And I fill "applicant-extra-employment-information-details-field" with "Yorke also earns 50 gbp"
    And I click 'Save and continue'

    Then I should be on a page showing "Which of these payments does your client get?"
    When I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client gets in cash"

    When I select "My client gets none of these payments in cash"
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
    Then I should be on a page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"

    When I click 'Continue'
    Then I should be on a page showing "Does your client own the home they usually live in?"

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
    Then I should be on a page showing "Disregarded payments"

    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"

    When I check "My client has not received any of these payments"
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
    And I enter the 'told' date of 2 days ago using the date picker field
    And I enter the 'occurred' date of 2 days ago using the date picker field

    When I click 'Save and continue'
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
    Then I should be on a page showing "Statement of case"

    When I select "Type a statement"
    And I fill "application-merits-task-statement-of-case-statement-field" with "Statement of case"
    And I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"

    When I click link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 45% or better?"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"

    When I click 'Save and continue'
    Then I should be on a page showing "Upload supporting evidence"
    And I should see "Use this page to upload evidence of your client's employment."

    When I upload an evidence file named 'hello_world.pdf'
    And I sleep for 2 seconds
    And I select a category of "Client's employment evidence" for the file "hello_world.pdf"
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"

    When I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"

    When I check "I confirm the above is correct and that I'll get a signed declaration from my client"
    And I click 'Save and continue'
    Then I should be on a page showing "Print and submit your application"

    When I click 'Submit and continue'
    Then I should be on a page showing "Application complete"

    When I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
