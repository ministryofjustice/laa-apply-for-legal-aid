Feature: Scope limitations not being set

  @javascript @stub_pda_provider_details @vcr @billy
  Scenario: When a provider creates an application with multiple proceedings and uses the back button, scope limitations should not be removed
    Given I start the journey as far as the applicant page
    When I enter name 'Test', 'User'
    Then I choose 'No'
    And I enter the date of birth '03-04-1999'
    When I click 'Save and continue'
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
    Then I should be on a page showing "Do you want to link this application with another one?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'SE014'
    And proceeding suggestions has results
    And I choose a 'Child arrangements order (CAO) - residence' radio button
    When I click 'Save and continue'

    Then I should be on a page showing 'You have added 1 proceeding'
    And I should be on a page showing 'Child arrangements order (CAO) - residence'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'Yes'
    And I click 'Save and continue'

    Then I should be on a page showing 'Search for legal proceedings'
    When I search for proceeding 'SE003'
    And proceeding suggestions has results
    Then I should be on a page showing 'Prohibited steps order'
    And proceeding suggestions has results
    When I choose a 'Prohibited steps order - enforcement' radio button
    And I click 'Save and continue'

    Then I should be on a page showing 'Is this proceeding for a change of name application?'
    When I choose 'No'
    And I click 'Save and continue'

    Then I should be on a page showing 'You have added 2 proceedings'
    And I should be on a page showing 'Child arrangements order (CAO) - residence'
    And I should be on a page showing 'Prohibited steps order'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'Yes'
    And I click 'Save and continue'

    Then I should be on a page showing 'Search for legal proceedings'
    When I search for proceeding 'SE004A'
    And proceeding suggestions has results
    Then I should be on a page showing 'Specific issue order - appeal'
    And proceeding suggestions has results
    When I choose a 'Specific issue order - appeal' radio button
    And I click 'Save and continue'

    Then I should be on a page showing 'Is this proceeding for a change of name application?'
    When I choose 'No'
    And I click 'Save and continue'

    Then I should be on a page showing 'You have added 3 proceedings'
    And I should be on a page showing 'Child arrangements order (CAO) - residence'
    And I should be on a page showing 'Prohibited steps order'
    And I should be on a page showing 'Specific issue order - appeal'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'

    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(CAO\) - residence\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'

    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(CAO\) - residence\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 2 days ago using the date picker field
    When I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(CAO\) - residence'
    And I should see 'Do you want to use the default level of service and scope for the emergency application?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(CAO\) - residence\nFor the emergency application, select the level of service'

    When I choose "Family Help (Higher)"
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(CAO\) - residence\nFor the emergency application, select the scope'

    # clicks back until on add_other_proceedings
    When I click link "Back"
    And I click link "Back"
    And I click link "Back"
    And I click link "Back"
    And I click link "Back"
    Then I should be on a page showing 'You have added 3 proceedings'
    And I should be on a page showing 'Child arrangements order (CAO) - residence'
    And I should be on a page showing 'Prohibited steps order'
    And I should be on a page showing 'Specific issue order - appeal'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    # at this point proceeding one is incomplete and should be resumed
    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(CAO\) - residence\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
