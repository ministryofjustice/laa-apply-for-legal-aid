Feature: passported_journey completes application
  @javascript @vcr
  Scenario: Receives benefits and completes the application happy path no back button
    Given csrf is enabled
    Given I complete the passported journey as far as check your answers for client details
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client receives a passporting benefit'
    Then I click 'Continue'
    Then I should be on a page showing "What you need to do"
    Then I click 'Continue'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's home"
    Then I fill "Property value" with "200000"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I choose "Yes, an ex-partner"
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select "Current account"
    Then I fill "offline_current_accounts" with "10"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
    Then I select "Money not in a bank account"
    Then I fill "Cash" with "10000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    Then I select "Land"
    Then I fill "Land value" with "50000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client banned from selling or borrowing against their assets?"
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on a page showing "Disregarded payments"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"
    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    Then I should be on a page showing 'We need to check if Test Walker can get legal aid'
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Latest incident details Not started'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page with title "Is the opponent an individual or an organisation?"
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
    And I choose option "application merits task domestic abuse summary warning letter sent True field"
    Then I choose option "application merits task domestic abuse summary police notified True field"
    Then I choose option "application merits task domestic abuse summary bail conditions set True field"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    Then I should be on a page showing "Statement of case"

    When I select "Upload a statement"
    And I select "Type a statement"
    And I fill "Application merits task statement of case statement field" with "Statement of case"
    When I click 'Save and continue'
    Then I should be on a page with title "Upload statement of case"

    When I upload an evidence file named 'hello_world.pdf'
    Then I should not see "There was a problem uploading your file"
    Then I should be on a page showing "hello_world.pdf"
    Then I should be on a page showing "Uploaded"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Not started'
    When I click link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 45% or better?"
    Then I choose "No"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Completed'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And I click Check Your Answers Change link for 'Statement of Case'
    Then I enter the application merits task statement of case statement field 'This is some test data for the statement of case'
    Then I click 'Save and continue'
    Then I should be on a page with title "Upload statement of case"
    And I should be on a page showing "hello_world.pdf"
    When I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the answer for 'Statement of case file' should be 'hello_world.pdf (15.7 KB)'
    And I should be on a page showing "This is some test data for the statement of case"
    Then I click 'Save and continue'
    And I should be on a page showing "Confirm the following"
    Then I check "I confirm the above is correct and that I'll get a signed declaration from my client"
    Then I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"

  @javascript @vcr
  Scenario: When Provider accepts non-passported DWP result, continues, then goes back to change
    Given I complete the non-passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client does not get a passporting benefit'
    Then I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you need to do"
    And I click link 'Back'
    And I should be on a page showing 'DWP records show that your client does not get a passporting benefit'
    Then I choose 'No, my client gets a passporting benefit'
    And I click 'Save and continue'
    And I should be on a page showing "Check your client's details"
    And I click 'Save and continue'
    And I should be on a page showing 'Which passporting benefit does your client get?'
    Then I choose 'Universal Credit'
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you have evidence that your client receives Universal Credit?'
    And I choose 'Yes'
    Then I scroll down
    And I click 'Save and continue'
    Then I should be on a page showing "What you need to do"
    And I click 'Continue'
    And I should be on a page showing 'Does your client own the home they usually live in?'

  @javascript @vcr
  Scenario: A negative benefit check allows the solicitor to override the result
    Given I complete the non-passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client does not get a passporting benefit'
    Then I choose 'No, my client gets a passporting benefit'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your client's details"
    Then I click the first link "Client name"
    Then I should be on a page showing "Enter your client's details"
    When I click link "Back"
    And I click 'Save and continue'
    Then I should be on a page showing 'Which passporting benefit does your client get?'
    Then I choose 'None of these'
    And I click 'Save and continue'
    Then I should be on a page showing "What you need to do"
    When I click link "Back"
    Then I choose 'Income Support'
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you have evidence that your client receives Income Support?'
    Then I choose "Yes"
    Then I scroll down
    Then I click 'Save and continue'
    Then I should be on a page showing 'What you need to do'
    When I click link "Back"
    Then I should be on a page showing 'Do you have evidence that your client receives Income Support?'
    Then I choose 'No'
    Then I scroll down
    Then I click 'Save and continue'
    Then I should be on a page showing "What you need to do"
