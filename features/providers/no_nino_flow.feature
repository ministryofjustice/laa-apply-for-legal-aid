Feature: No national insurance number for applicant

  @javascript @vcr
  Scenario: I can see that the applicant receives benefits
    Given I start the journey as far as the applicant page
    And a "bank holiday" exists in the database

    When I enter name 'Test', 'Walker'
    And I enter the date of birth '10-1-1980'
    And I click 'Save and continue'
    Then I should be on a page with title "Enter your client's correspondence address"

    When I enter a postcode 'SW1H 9EA'
    And I click "Find address"
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page showing "What does your client want legal aid for?"

    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client’s role in this proceeding?'

    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'

    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"

    When I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number "JA123456D"
    And I click 'Save and continue'
    Then I should be on a page with title 'Check your answers'

    When I click Check Your Answers Change link for "National Insurance number"
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page showing "You will have to do a full means test as part of this application. This is because you do not have a National Insurance number for your client"

    When I click link 'Back'
    Then I should be on a page with title 'Check your answers'
    And I click 'Save and continue'

    When I click "Continue"
    Then I should be on a page with title "What is your client's employment status?"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "We need your client's bank statements from the last 3 months"
