Feature: Merits task list

  @javascript @vcr
  Scenario: When the flag is enabled
    Given the feature flag for allow_multiple_proceedings is enabled
    And the method populate of ProceedingType is rerun
    And the method populate of ProceedingTypeScopeLimitation is rerun
    When I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application\nNOT STARTED'
    And I should see 'Children involved in this proceeding\nCANNOT START YET'
    When I click 'Continue'
    Then I should be on the 'merits_task_list' page showing 'You must complete every section before you can continue'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago
    And I enter the 'occurred' date of 2 days ago
    When I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    When I fill "Full Name" with "John Doe"
    And I choose option "Application merits task opponent understands terms of court order True field"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I choose option "Application merits task opponent bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    When I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    When I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old
    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
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
    Then I should be on the 'merits_task_list' page showing 'Chances of success\nCOMPLETED'
    When I click link 'Children involved in this proceeding'
    Then I should be on the 'linked_children' page showing 'Which children are covered under this proceeding?'
    When I select 'John Doe Jr'
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Children involved in this proceeding\nCOMPLETED'
    When I click link 'Attempts to settle'
    Then I should be on the 'attempts_to_settle' page showing 'What attempts have been made to settle the matter?'
    When I fill "Attempts made" with "A settlement attempt"
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Attempts to settle\nCOMPLETED'
    When I click 'Continue'
    Then I should be on the 'gateway_evidence' page showing 'Upload supporting evidence'
    And I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers and submit application'
    And the page is accessible

  @javascript @vcr
  Scenario: Removing children
    Given the feature flag for allow_multiple_proceedings is enabled
    And the method populate of ProceedingType is rerun
    And the method populate of ProceedingTypeScopeLimitation is rerun
    When I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Children involved in this application\nNOT STARTED'
    And I should see 'Children involved in this proceeding\nCANNOT START YET'
    When I click 'Continue'
    Then I should be on the 'merits_task_list' page showing 'You must complete every section before you can continue'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago
    And I enter the 'occurred' date of 2 days ago
    When I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    When I fill "Full Name" with "John Doe"
    And I choose option "Application merits task opponent understands terms of court order True field"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I choose option "Application merits task opponent bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    When I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    When I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'
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
    Then I should be on the 'applications' page showing 'Your applications'

  @javascript @vcr
  Scenario: When the flag is disabled
    Given the feature flag for allow_multiple_proceedings is disabled
    And the method populate of ProceedingType is rerun
    And the method populate of ProceedingTypeScopeLimitation is rerun
    And I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Child arrangements order'
    Then proceeding suggestions has no results
    Then I search for proceeding 'non-mol'
    Then proceeding suggestions has results
    When I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
