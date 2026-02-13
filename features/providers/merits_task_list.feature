Feature: Merits task list

  @javascript @vcr
  Scenario: Completing the merits task list
    When I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application Not started'
    And I should see 'Children involved in this proceeding Cannot start yet'
    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'You must complete every section before you can continue'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago using the date picker field
    And I enter the 'occurred' date of 2 days ago using the date picker field
    When I click 'Save and continue'
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
    And I choose option "application merits task domestic abuse summary police notified True field"
    And I choose option "application merits task domestic abuse summary bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    When I click 'Save and continue'
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old
    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing "Statement of case"

    When I select "Type a statement"
    And I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'
    Then I should be on the 'matter_opposed_reason' page showing "Why is the Section 8 matter opposed by your client or the other party?"
    And I fill "Reason" with "Because it is opposed."
    And I click 'Save and continue'
    Then I should be on the 'in_scope_of_laspo' page showing "Are the Section 8 proceedings you're applying for in scope of the Legal Aid"
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application Completed'
    And I should see 'Children involved in this proceeding Not started'
    When I click the first link 'Chances of success'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 45% or better?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Completed'
    When I click the last link 'Chances of success'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 45% or better?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'linked_children' page showing 'Which children are covered under this proceeding?'
    When I select 'John Doe Jr'
    And I click 'Save and continue'
    Then I should be on the 'attempts_to_settle' page showing 'What attempts have been made to settle the matter?'
    When I fill "Attempts made" with "A settlement attempt"
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Attempts to settle Completed'
    When I click 'Save and continue'
    Then I should be on a page showing 'Upload supporting evidence'
    And I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    Then I click Check Your Merits Answers Change link for 'Success Likely' for 'Inherent jurisdiction high court injunction'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 45% or better?'
    And I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'

  @javascript @vcr
  Scenario: Removing children
    When I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application Not started'
    And I should see 'Children involved in this proceeding Cannot start yet'
    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'You must complete every section before you can continue'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago using the date picker field
    And I enter the 'occurred' date of 2 days ago using the date picker field
    When I click 'Save and continue'
    Then I should be on a page with title "Is the opponent an individual or an organisation?"
    And I choose a 'An individual' radio button
    When I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    When I fill "First Name" with "John"
    Then I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page with title "You have added 1 opponent"
    And I should be on a page showing "Do you need to add another opponent?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page with title "Is the opponent an individual or an organisation?"
    And I choose a 'An individual' radio button
    When I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    When I fill "First Name" with "Jane"
    Then I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page with title "You have added 2 opponents"
    And I should be on a page showing "Do you need to add another opponent?"
    When I click 'Save and continue'
    Then I should be on a page showing "You have added 2 opponents"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    And I choose option "application merits task domestic abuse summary warning letter sent True field"
    And I choose option "application merits task domestic abuse summary police notified True field"
    And I choose option "application merits task domestic abuse summary bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    When I click 'Save and continue'
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old
    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
    When I click link 'Remove'
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I click 'Save and come back later'
    Then I should be on the 'applications/in_progress' page showing 'Your applications'

  @javascript @clamav
  Scenario: Uploading a file for statement of case
    Given csrf is enabled
    Given I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application Not started'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago using the date picker field
    And I enter the 'occurred' date of 2 days ago using the date picker field
    When I click 'Save and continue'
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
    And I choose option "application merits task domestic abuse summary police notified True field"
    And I choose option "application merits task domestic abuse summary bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    When I click 'Save and continue'
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old
    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing "Statement of case"
    When I select "Upload a statement"
    And I click 'Save and continue'
    And I upload an evidence file named 'hello_world.pdf'
    Then I should see 'hello_world.pdf'
    And I should see 1 uploaded files
    When I click 'Delete'
    Then I should see 'hello_world.pdf has been successfully deleted'
    And I should see 0 uploaded files
    Then I upload an evidence file named 'hello_world.pdf'
    And I should see 'hello_world.pdf'
    And I should see 1 uploaded files
    When I click 'Save and continue'
    When I click link 'Back'
    Then I should be on a page showing "Upload statement of case"
    When I click 'Save and continue'

    Then I should be on the 'matter_opposed_reason' page showing "Why is the Section 8 matter opposed by your client or the other party?"
    And I fill "Reason" with "Because it is opposed."
    And I click 'Save and continue'
    Then I should be on the 'in_scope_of_laspo' page showing "Are the Section 8 proceedings you're applying for in scope of the Legal Aid"
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Statement of case Completed'

  @javascript @vcr
  Scenario: Completes the merits application for applicant that does not receive passported benefits
    Given I have completed the non-passported means assessment and start the merits assessment
    Then I should be on the 'merits_task_list' page showing 'Latest incident details Not started'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    Then I enter the 'told' date of 2 days ago using the date picker field
    Then I enter the 'occurred' date of 2 days ago using the date picker field
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
    And I should not see "Proceedings currently before court"
    Then I should be on a page showing "Statement of case"

    When I select "Type a statement"
    And I fill "Application merits task statement of case statement field" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Not started'
    When I click the last link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 45% or better?"
    Then I choose "No"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success Completed'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"
    Then I check "I confirm the above is correct and that I'll get a signed declaration from my client"
    Then I click 'Save and continue'
    Then I should be on a page showing "Print and submit your application"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And I should not see "Passported"
