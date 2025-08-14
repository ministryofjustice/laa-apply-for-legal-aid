Feature: Using the back button on proceedings should not lock a user out
  @javascript @vcr @stub_pda_provider_details
  Scenario: When a provider is adding proceedings and uses the back button they should route to the list of proceedings first
    Given I start the journey as far as the applicant page
    When I enter name 'Test', 'User'
    Then I choose 'No'
    And I enter the date of birth '03-04-1999'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I should be on a page showing "Has your client applied for civil legal aid before?"
    Then I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "Where should we send your client's correspondence?"
    When I choose "My client's UK home address"
    And I click "Save and continue"
    Then I am on the postcode entry page

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    When I click 'Use this address'

    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    When I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

    When I click link "Back"
    And I click link "Back"
    Then I should be on a page showing "Select your client's home address"

    When I click "Use this address"
    Then I should be on a page showing 'Do you want to add another proceeding?'
