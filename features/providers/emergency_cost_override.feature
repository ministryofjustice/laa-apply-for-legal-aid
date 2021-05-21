Feature: Emergency cost override
  @javascript @vcr
  Scenario: Provider is prompted to override emergency cost limitation
    Given I start the journey as far as the applicant page
    And the setting to allow multiple proceedings is enabled
    When I enter name 'Test', 'User'
    And I enter the date of birth '03-04-1999'
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I am on the postcode entry page
    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    When I click 'Save and continue'
    When I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    When I choose a proceeding type 'Non-molestation order' radio button
    When I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'
    When I select 'Non-molestation order'
    And I enter the 'nonmolestation order used delegated functions on' date of 5 days ago
    When I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    And I should see 'Do you want to request a higher cost limit?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    When I click link "Back"
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Do you want to request a higher cost limit?"
    When I choose 'Yes'
    And I enter a emergency cost requested '5000'
    And I enter legal aid application emergency cost reasons field 'This is why I require extra funding'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page showing "Emergency cost limit"
