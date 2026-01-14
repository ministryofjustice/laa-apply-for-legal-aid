Feature: Pathways from check your answers

  @javascript @vcr
  Scenario: I do not use delegated functions
    Given I complete the journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit. Is this correct?"
    When I click "Yes, continue"
    Then I should be on a page showing 'What you need to do'
    When I click 'Continue'
    Then I should be on a page showing "What is your client's employment status?"
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client use online banking?"

  @javascript @vcr
  Scenario: I do not use delegated functions for a passported journey
    Given I complete the passported journey as far as check your answers for client details
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client receives a passporting benefit'
    Then I click 'Save and continue'
    Then I should be on the 'capital_introduction' page showing "What you need to do"

  @javascript @vcr
  Scenario: I use delegated functions and will return later
    Given I complete the journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit. Is this correct?"
    When I click "Yes, continue"
    Then I should be on a page showing 'What you need to do'
    When I click 'Continue'
    Then I should be on a page showing "What is your client's employment status?"
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "You told us you've used delegated functions"
    Then I click link 'Back to your applications'
    Then I should be on a page showing 'Your applications'

  @javascript @vcr
  Scenario: I use delegated functions and a substantive application
    Given I complete the journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit. Is this correct?"
    When I click "Yes, continue"
    Then I should be on a page showing 'What you need to do'
    When I click 'Continue'
    Then I should be on a page showing "What is your client's employment status?"
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title "Does your client use online banking?"

  @javascript @vcr
  Scenario: I use delegated functions and a substantive application for a passported journey
    Given I complete the passported journey as far as check your answers for client details
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client receives a passporting benefit'
    Then I click 'continue_button'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on the 'capital_introduction' page showing "What you need to do"

  @javascript @vcr @billy
  Scenario: I go back and change the proceedings on an application with multiple proceedings
    Given I complete the journey as far as check client details with multiple proceedings selected
    When I click Check Your Answers summary card Change link for 'Proceedings'
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
    Then I search for proceeding 'Child arrangements order CAO Section 8'
    Then proceeding suggestions has results
    Then I choose a 'Child arrangements order (CAO) - contact - appeal' radio button
    And I click 'Save and continue'
    Then I should be on the 'has_other_proceedings' page showing 'Do you want to add another proceeding?'
    And I should be on a page showing 'Child arrangements order (CAO) - contact - appeal'
    Then I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(CAO\) - contact - appeal\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(CAO\) - contact - appeal\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(CAO\) - contact - appeal'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'limitations' page showing "What you're applying for"
    When I click 'Save and continue'
    Then I should be on a page showing 'Does your client have a partner?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'check_provider_answers' page showing 'Check your answers'
    And I should be on a page showing 'Non-molestation order'
    And I should be on a page showing 'Child arrangements order (CAO) - contact - appeal'
