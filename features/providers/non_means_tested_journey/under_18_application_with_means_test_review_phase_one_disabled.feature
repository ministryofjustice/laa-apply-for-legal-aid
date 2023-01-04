Feature: Under 18 applicant journey with means test review phase one disabled

  @javascript @vcr
  Scenario: Completes a minimal application for applicant that is under 18 with MTR phase 1 disabled
    Given I am logged in as a provider

    When I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'

    When I click 'Agree and continue'
    Then I should be on the Applicant page

    When I enter name 'Test', 'User'
    And I enter a date of birth that will make me 18 tomorrow
    And I click 'Save and continue'
    Then I am on the postcode entry page

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page showing "What does your client want legal aid for?"

    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Non-molestation order'
    And I should be on a page showing 'Do you want to add another proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client’s role in this proceeding?'

    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "What you're applying for"

    When I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number 'CB987654A'
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

    When I click 'Save and continue'
    And I should be on a page showing "DWP records show that your client does not receive a passporting benefit – is this correct?"
