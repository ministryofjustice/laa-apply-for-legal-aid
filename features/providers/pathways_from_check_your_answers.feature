Feature: Pathways from check your answers

  @javascript @vcr
  Scenario: I do not use delegated functions
    Given I complete the journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not receive a passporting benefit – is this correct?"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What is your client's employment status?"
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page with title "We need your client's bank statements from the last 3 months"

  @javascript @vcr
  Scenario: I do not use delegated functions for a passported journey
    Given I complete the passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client receives a passporting benefit'
    Then I click 'Continue'
    Then I should be on the 'capital_introduction' page showing "What you need to do"

  @javascript @vcr
  Scenario: I use delegated functions and will return later
    Given I complete the journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not receive a passporting benefit – is this correct?"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What is your client's employment status?"
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page with title "We need your client's bank statements from the last 3 months"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "You told us you've used delegated functions"
    Then I click link 'Back to your applications'
    Then I should be on a page showing 'Applications'

  @javascript @vcr
  Scenario: I use delegated functions and a substantive application
    Given I complete the journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not receive a passporting benefit – is this correct?"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What is your client's employment status?"
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page with title "We need your client's bank statements from the last 3 months"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'What your client has to do'
    Then I click link 'Continue'
    Then I should be on a page showing "Enter your client's email address"

  @javascript @vcr
  Scenario: I use delegated functions and a substantive application for a passported journey
    Given I complete the passported journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client receives a passporting benefit'
    Then I click 'continue_button'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on the 'capital_introduction' page showing "What you need to do"

  @javascript @vcr
  Scenario: I go back and change the proceedings on an application with multiple proceedings
    Given I complete the journey as far as check client details with multiple proceedings selected
    When I click Check Your Answers Change link for 'Proceedings'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    And I should be on a page showing 'Inherent jurisdiction high court injunction'
    And I should be on a page showing 'Occupation order'
    Then I click the first link 'Remove'
    Then I should not see 'Inherent jurisdiction high court injunction'
    Then I click the first link 'Remove'
    Then I should not see 'Occupation order'
    Then I should be on the 'proceedings_types' page showing 'What does your client want legal aid for?'
    And I should not see 'Back'
    When I click the browser back button
    Then I should be on the 'proceedings_types' page showing 'What does your client want legal aid for?'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on the 'has_other_proceedings' page showing 'Non-molestation order'
    Then I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'proceedings_types' page showing 'What does your client want legal aid for?'
    And I should see 'Back'
    When I click the first link 'Back'
    Then I should be on the 'has_other_proceedings' page showing 'Do you want to add another proceeding?'
    Then I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'proceedings_types' page showing 'What does your client want legal aid for?'
    Then I search for proceeding 'Child arrangements order'
    Then proceeding suggestions has results
    Then I choose a 'Child arrangements order (contact)' radio button
    And I click 'Save and continue'
    Then I should be on the 'has_other_proceedings' page showing 'Do you want to add another proceeding?'
    And I should be on a page showing 'Child arrangements order (contact)'
    Then I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing "Are the Section 8 proceedings you're applying for in scope of the Legal Aid, Sentencing and Punishment of Offenders Act 2012 (LASPO)?"
    Then I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'
    Then I select 'I have not used delegated functions'
    And I click 'Save and continue'
    Then I should be on the 'limitations' page showing "What you're applying for"
    And I click 'Save and continue'
    Then I should be on the 'check_provider_answers' page showing 'Check your answers'
    And I should be on a page showing 'Non-molestation order'
    And I should be on a page showing 'Child arrangements order (contact)'
    And I should be on a page showing 'LASPO'
    And the answer for 'in scope of laspo' should be 'Yes'

  @javascript @vcr
  Scenario: I go back and change the delegated functions on an application with multiple proceedings
    Given I complete the journey as far as check client details with multiple proceedings selected
    When I click Check Your Answers Change link for 'Delegated functions'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'
    Then I select 'Occupation order'
    Then I enter the 'occupation order used delegated functions on' date of 35 days ago
    Then I select 'Inherent jurisdiction high court injunction'
    Then I enter the 'inherent jurisdiction high court injunction used delegated functions on' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check delegated functions dates'
    When I click link 'Back'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'
    And I should be on a page showing 'Date you used delegated functions'
    And I should see a 'occupation order used delegated functions on' date of 35 days ago
    And I should see a 'inherent jurisdiction high court injunction used delegated functions on' date of 2 days ago

  @javascript @vcr
  Scenario: I click the back button on the DWP override page
    Given I complete the non-passported journey as far as check your answers
    When I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client does not receive a passporting benefit – is this correct?'
    When I click link 'Back'
    Then I should be on a page showing 'Check your answers'
