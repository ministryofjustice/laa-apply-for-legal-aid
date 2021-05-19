Feature: Merits task list

  @javascript @vcr
  Scenario: Merits Task list functions
    Given the feature flag for allow_multiple_proceedings is enabled
    And the method populate of ProceedingType is rerun
    And the method populate of ProceedingTypeScopeLimitation is rerun
    Given I previously created a passported application with multiple_proceedings and left on the "check_passported_answers" page
    Then I visit the applications page
    Then I view the previously created application
    Then I am on the check your answers page for other assets
    When I click 'Save and continue'
    Then I should be on the 'capital_assessment_result' page showing 'could be eligible for legal aid'
    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'
    And I should see regex Latest incident details\nNOT STARTED
    And I should see regex Opponent details\nNOT STARTED
    And I should see regex Statement of case\nNOT STARTED
    And I should see regex Children involved in this application\nNOT STARTED
    And I should see regex Children involved in this proceeding\nCANNOT START YET
    When I click link 'Latest incident details'
    Then I should be on the 'date_client_told_incident' page showing 'Latest incident details'
    When I enter the 'told_on' date of 9 days ago
    And I enter the 'occurred_on' date of 10 days ago
    And I click 'Save and continue'
    Then I should be on the 'opponent' page showing 'Opponent details'
    When I enter full_name 'Bob Smith'
    When I choose option "Application merits task opponent understands terms of court order True field"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I choose option "Application merits task opponent bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    And I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    When I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'
    Then I should be on the 'involved_children/new' page showing "Enter details of the children involved in this application"
    When I fill "Name" with "Wednesday Adams"
    And I enter a 'date_of_birth' for a 17 year old
    And I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing "Do you need to add another child?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'
    And I should see regex Latest incident details\nCOMPLETED
    And I should see regex Opponent details\nCOMPLETED
    And I should see regex Statement of case\nCOMPLETED
    And I should see regex Children involved in this application\nCOMPLETED
    And I should see regex Children involved in this proceeding\nNOT STARTED
    When I click 'Continue'
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'
    And I should see 'You must complete every section before you can continue'
