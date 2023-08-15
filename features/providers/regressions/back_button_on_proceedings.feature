Feature: Using the back button on proceedings should not lock a user out
  @javascript @vcr
  Scenario: When a provider is adding proceedings and uses the back button they should route to the list of proceedings first
    Given I start the journey as far as the applicant page
    When I enter name 'Test', 'User'
    And I enter the date of birth '03-04-1999'
    And I click 'Save and continue'
    Then I am on the postcode entry page

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    When I click 'Save and continue'

    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    When I choose a proceeding type 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

    When I click link "Back"
    And I click link "Back"
    Then I should be on a page showing "Enter your client's correspondence address"

    When I click "Save and continue"
    Then I should be on a page showing 'Do you want to add another proceeding?'
