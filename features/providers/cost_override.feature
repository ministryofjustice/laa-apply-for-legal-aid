Feature: Emergency cost override
  @javascript @vcr
  Scenario: Provider is prompted to override emergency cost limitation
    Given I start the journey as far as the applicant page
    When I enter name 'Test', 'User'
    Then I choose 'No'
    And I enter the date of birth '03-04-1999'
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
    And I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    When I choose a proceeding type 'Non-molestation order' radio button
    When I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 5 days ago
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the emergency application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    And I should see 'Do you want to request a higher emergency cost limit?'
    When I choose 'No'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    When I click link "Back"
    Then I should be on a page with title "Does your client have a partner?"
    When I click link "Back"
    Then I should be on a page with title "Does your client have a National Insurance number?"
    When I click link "Back"
    Then I should be on a page showing "What you're applying for"
    Then I should see "Do you want to request a higher emergency cost limit?"
    When I choose 'Yes'
    And I enter a emergency cost requested '5000'
    And I enter legal aid application emergency cost reasons field 'This is why I require extra funding'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    When I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should see "Emergency cost limit"

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

