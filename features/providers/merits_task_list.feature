Feature: Merits task list

  @javascript @vcr
  Scenario: Completing the merits task list
    When I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application\nNOT STARTED'
    And I should see 'Children involved in this proceeding\nCANNOT START YET'
    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'You must complete every section before you can continue'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago
    And I enter the 'occurred' date of 2 days ago
    When I click 'Save and continue'
    Then I should be on a page showing "Opponent's name"
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I choose option "Application merits task opponent bail conditions set True field"
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
    Then I should be on a page showing "Provide a statement of case"
    When I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'
    Then I should be on the 'matter_opposed_reason' page showing "Why is the matter opposed by your client or the other party?"
    And I fill "Reason" with "Because it is opposed."
    And I click 'Save and continue'
    Then I should be on the 'in_scope_of_laspo' page showing "Are the Section 8 proceedings you're applying for in scope of the Legal Aid"
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application\nCOMPLETED'
    And I should see 'Children involved in this proceeding\nNOT STARTED'
    When I click the first link 'Chances of success'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 50% or better?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success\nCOMPLETED'
    When I click the last link 'Chances of success'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 50% or better?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'linked_children' page showing 'Which children are covered under this proceeding?'
    When I select 'John Doe Jr'
    And I click 'Save and continue'
    Then I should be on the 'attempts_to_settle' page showing 'What attempts have been made to settle the matter?'
    When I fill "Attempts made" with "A settlement attempt"
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Attempts to settle\nCOMPLETED'
    When I click 'Save and continue'
    Then I should be on a page showing 'Upload supporting evidence'
    And I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the page is accessible
    Then I click Check Your Merits Answers Change link for 'Success Likely' for 'Inherent jurisdiction high court injunction'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 50% or better?'
    And I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'

  @javascript @vcr
  Scenario: Removing children
    When I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application\nNOT STARTED'
    And I should see 'Children involved in this proceeding\nCANNOT START YET'
    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'You must complete every section before you can continue'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago
    And I enter the 'occurred' date of 2 days ago
    When I click 'Save and continue'
    Then I should be on a page showing "Opponent's name"
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I choose option "Application merits task opponent bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    When I click 'Save and continue'
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old
    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
    When I click link 'Remove'
    Then I should be on a page showing 'Do you want to remove John Doe Jr from the application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I click 'Save and come back later'
    Then I should be on the 'applications' page showing 'Applications'

  @javascript @clamav
  Scenario: Uploading a file for statement of case
    Given csrf is enabled
    Given I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application\nNOT STARTED'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago
    And I enter the 'occurred' date of 2 days ago
    When I click 'Save and continue'
    Then I should be on a page showing "Opponent's name"
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I choose option "Application merits task opponent bail conditions set True field"
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
    Then I should be on a page showing "Provide a statement of case"
    When I upload an evidence file named 'hello_world.pdf'
    Then I should see 'hello_world.pdf'
    And I should see 'UPLOADED'
    When I click 'Delete'
    Then I should see 'hello_world.pdf has been successfully deleted'
    And I should not see 'UPLOADED'
    Then I upload an evidence file named 'hello_world.pdf'
    And I should see 'UPLOADED'
    When I click 'Save and continue'
    Then I should be on the 'matter_opposed_reason' page showing "Why is the matter opposed by your client or the other party?"
    And I fill "Reason" with "Because it is opposed."
    And I click 'Save and continue'
    Then I should be on the 'in_scope_of_laspo' page showing "Are the Section 8 proceedings you're applying for in scope of the Legal Aid"
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Statement of case\nCOMPLETED'
