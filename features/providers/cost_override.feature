Feature: Emergency cost override
  @javascript @vcr
  Scenario: Provider is prompted to override emergency cost limitation
    Given I start the journey as far as the applicant page
    When I enter name 'Test', 'User'
    And I enter the date of birth '03-04-1999'
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I am on the postcode entry page
    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    When I click 'Save and continue'
    And I should be on a page showing "What does your client want legal aid for?"
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
    And I should see 'Do you want to request a higher emergency cost limit?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    When I click link "Back"
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Do you want to request a higher emergency cost limit?"
    When I choose 'Yes'
    And I enter a emergency cost requested '5000'
    And I enter legal aid application emergency cost reasons field 'This is why I require extra funding'
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page showing "Emergency cost limit"

  @javascript @vcr
  Scenario: Provider should be able to request a higher substantive cost limit when the default substantive cost limit is below the 25,000 threshold
    Given I view the limitations for an application with proceedings below the max threshold
    Then I should see "What you're applying for"
    And I should see "Do you want to request a higher substantive cost limit?"
    And I should not see "Do you want to request a higher emergency cost limit?"

  @javascript @vcr
  Scenario: Provider should not be able to request a higher substantive cost limit when the default substantive cost limit is at the 25,000 threshold
    Given I view the limitations for an application with proceedings at the max threshold
    Then I should see "What you're applying for"
    And I should not see "Do you want to request a higher substantive cost limit?"
    And I should not see "Do you want to request a higher emergency cost limit?"

  @javascript @vcr
  Scenario: Provider should be able to increase both cost limits when the default substantive cost limit is below the 25,000 threshold and they have used DF
    Given I view the limitations for an application with proceedings below the max threshold with delegated_functions
    Then I should see "What you're applying for"
    And I should see "Do you want to request a higher substantive cost limit?"
    And I should see "Do you want to request a higher emergency cost limit?"

