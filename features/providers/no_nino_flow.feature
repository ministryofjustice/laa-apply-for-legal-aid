Feature: No national insurance number for applicant

  @javascript @stub_pda_provider_details @vcr @billy
  Scenario: I can see that the applicant receives benefits
    Given I start the journey as far as the applicant page
    And a "bank holiday" exists in the database

    When I enter name 'Test', 'Walker'
    Then I choose 'No'
    And I enter the date of birth '10-1-1980'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number "JA123456D"
    And I click 'Save and continue'
    Then I should be on a page showing "Has your client applied for civil legal aid before?"

    Then I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "Where should we send your client's correspondence?"
    When I choose "My client's UK home address"
    And I click "Save and continue"
    Then I should be on a page with title "Find your client's home address"

    When I enter a postcode 'SW1H 9EA'
    And I click "Find address"
    And I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    And I click 'Use this address'
    Then I should be on a page showing "Do you want to link this application with another one?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "What does your client want legal aid for?"

    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'

    When I choose 'Applicant, claimant or petitioner'
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
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page with title 'Check your answers'

    When I click Check Your Answers Change link for "National Insurance number"
    Then I should be on a page with title "Does your client have a National Insurance number?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page showing "You will have to do a full means test as part of this application"

    When I click "Continue"
    Then I should be on a page with title "What is your client's employment status?"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client use online banking?"
