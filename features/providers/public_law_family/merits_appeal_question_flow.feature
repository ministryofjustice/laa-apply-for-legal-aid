Feature: Public law family merits appeal question flow

  @javascript
  Scenario: When application is for public law family second appeal
    Given I complete the journey as far as merits task list for a PLF proceeding with second appeal question
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'

    Then I should see "About the application"
    And I should see 'Opponents Not started'
    And I should see 'Statement of case Not started'
    And I should see 'Children involved in this application Not started'
    And I should see 'The second appeal Not started'

    Then I should see "About the Declaration for overseas adoption - appeal"
    And I should see 'Children involved in this proceeding Cannot start yet'
    And I should see 'Chances of success Not started'

    ############################
    # opponent
    ############################
    When I click link 'Opponent'
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

    ############################
    # statement of case
    ############################
    Then I should be on a page showing "Provide a statement of case"
    When I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'

    ############################
    # Children involved...
    ############################
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old

    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
    When I choose 'No'
    And I click 'Save and continue'

    ############################
    # Second appeal
    ############################
    Then I should be on the 'second_appeal' page showing 'Is this a second appeal?'
    And I should see "This question will help us decide if a specialist caseworker should review your application."

    When I choose "No"
    And I click 'Save and continue'

    #############################
    # Original (case) judge level
    #############################
    Then I should be on the 'original_case_judge_level' page showing 'What level of judge heard the original case?'
    And I should see "This question will help us decide if a specialist caseworker should review your application."
    And I should be on a page showing "Family Panel Magistrates (Justices/JP)"
    And I should be on a page showing "Deputy District Judge (DDJ)"
    And I should be on a page showing "District Judge (DJ)"
    And I should be on a page showing "Recorder Circuit Judge (HHJ)"
    And I should be on a page showing "High Court Judge (J)"
    And I should see "Including those sitting as such with s9 ticket"

    # Test the error
    When I click "Save and continue"
    Then I should see govuk error summary "Select what level of judge heard the original case"

    When I choose "Recorder Circuit Judge (HHJ)"
    And I click "Save and continue"

    #############################
    # First appeal court type
    #############################
    Then I should be on the 'appeal_court_type' page showing 'Which court will the appeal be heard in?'
    And I should see "This question will help us decide if a specialist caseworker should review your application."
    And I should see "Court of appeal"
    And I should see "Supreme court"
    And I should see "Any other court"

    # Test the error
    And I click "Save and continue"
    Then I should see govuk error summary "Select which court the appeal will be heard in"

    When I choose "Any other court"
    And I click "Save and continue"
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'

    ############################
    # Second appeal - change
    ############################
    When I click link 'The second appeal'
    Then I should be on the 'second_appeal' page showing 'Is this a second appeal?'

    When I choose "Yes"
    And I click "Save and continue"

    #############################
    # Second appeal court type
    #############################
    Then I should be on the 'second_appeal_court_type' page showing 'Which court will the second appeal be heard in?'
    And I should see "This question will help us decide if a specialist caseworker should review your application."
    And I should see "Court of appeal"
    And I should see "Supreme court"
    And I should not see "Any other court"

    # Test the error
    And I click "Save and continue"
    Then I should see govuk error summary "Select which court the appeal will be heard in"

    When I choose "Court of appeal"
    And I click "Save and continue"
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'

    ############################
    # Second appeal - change
    ############################
    When I click link 'The second appeal'
    Then I should be on the 'second_appeal' page showing 'Is this a second appeal?'

    When I choose "No"
    And I click "Save and continue"

    ################################
    # Original (case) judge level
    # Test the old value was cleared
    ################################
    Then I should be on the 'original_case_judge_level' page showing 'What level of judge heard the original case?'
    When I click "Save and continue"
    Then I should see govuk error summary "Select what level of judge heard the original case"

    When I choose "High Court Judge (J)"
    And I click "Save and continue"

    ################################
    # First appeal court
    # Test the old value was cleared
    ################################
    Then I should be on the 'appeal_court_type' page showing 'Which court will the appeal be heard in?'
    When I click "Save and continue"
    Then I should see govuk error summary "Select which court the appeal will be heard in"


    ################################
    # Original (case) judge level
    # Test next question flow
    ################################
    When I click link "Back"
    Then I should be on the 'original_case_judge_level' page showing 'What level of judge heard the original case?'

    When I choose "Family Panel Magistrates (Justices/JP)"
    And I click "Save and continue"
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'
