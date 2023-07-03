Feature: Scope limitations not being set
  @javascript @vcr
  Scenario: When a provider creates an application with multiple proceedings and uses the back button, scope limitations should not be removed
    Given I start the journey as far as the applicant page
    When I enter name 'Test', 'User'
    And I enter the date of birth '03-04-1999'
    When I click 'Save and continue'
    Then I am on the postcode entry page

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    When I click 'Save and continue'

    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'SE014'
    And proceeding suggestions has results
    And I choose a 'Child arrangements order (residence)' radio button
    When I click 'Save and continue'

    Then I should be on a page showing 'You have added 1 proceeding'
    And I should be on a page showing 'Child arrangements order (residence)'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'Yes'
    And I click 'Save and continue'

    Then I should be on a page showing 'Search for legal proceedings'
    When I search for proceeding 'SE003'
    And proceeding suggestions has results
    Then I should be on a page showing 'Prohibited steps order'
    And proceeding suggestions has results
    When I choose a 'Prohibited steps order' radio button
    And I click 'Save and continue'

    Then I should be on a page showing 'You have added 2 proceedings'
    And I should be on a page showing 'Child arrangements order (residence)'
    And I should be on a page showing 'Prohibited steps order'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'Yes'
    And I click 'Save and continue'

    Then I should be on a page showing 'Search for legal proceedings'
    When I search for proceeding 'SE004'
    And proceeding suggestions has results
    Then I should be on a page showing 'Specific Issue Order'
    And proceeding suggestions has results
    When I choose a 'Specific Issue Order' radio button
    And I click 'Save and continue'

    Then I should be on a page showing 'You have added 3 proceedings'
    And I should be on a page showing 'Child arrangements order (residence)'
    And I should be on a page showing 'Prohibited steps order'
    And I should be on a page showing 'Specific Issue Order'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'

    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(residence\)\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'

    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(residence\)\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 2 days ago
    When I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(residence\)'
    And I should see 'Do you want to use the default level of service and scope for the emergency application?'
    When I choose 'No'
    And I click 'Save and continue'

    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(residence\)\nFor the emergency application, select the level of service'
    When I click 'Save and continue'

    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(residence\)\nFor the emergency application, select the scope'
    # clicks back until on add_other_proceedings
    When I click link "Back"
    When I click link "Back"
    When I click link "Back"
    When I click link "Back"
    When I click link "Back"

    Then I should be on a page showing 'You have added 3 proceedings'
    And I should be on a page showing 'Child arrangements order (residence)'
    And I should be on a page showing 'Prohibited steps order'
    And I should be on a page showing 'Specific Issue Order'
    And I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    # at this point proceeding one is incomplete and should be resumed
    Then I should see 'Proceeding 1 of 3\nChild arrangements order \(residence\)\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
