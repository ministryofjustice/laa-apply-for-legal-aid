Feature: Linking cases back button use
  @javascript @vcr @stub_pda_provider_details
  Scenario: Complete flow reversion with back button
    Given I am logged in as a provider
    And I have created and submitted an application with the application reference 'L-123-456'
    And the feature flag for linked_applications is enabled

    When I visit the application service
    And I click link "Start"
    And I choose '0X395U'
    And I click 'Save and continue'
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'

    When I click 'Agree and continue'
    Then I should be on the Applicant page

    And I enter name 'Test', 'User'
    And I choose 'No'
    And I enter the date of birth '01-01-1999'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'

    Then I should be on a page showing "Has your client applied for civil legal aid before?"
    Then I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Where should we send your client's correspondence?"

    When I choose 'Another UK residential address'
    And I click 'Save and continue'
    Then I should be on a page showing "Find your client's correspondence address"

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    And I click 'Use this address'
    Then I should be on a page with title "Do you want to add a 'care of' recipient for your client's mail?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have a home address?"

    When I choose "No, they have no fixed address"
    And I click "Save and continue"
    Then I should be on a page with title "Do you want to link this application with another one?"

    When I choose "Yes, I want to make a family link"
    And I click "Save and continue"
    Then I should be on a page with title "What is the LAA reference of the application you want to link to?"

    When I search for laa reference 'L-123-456'
    And I click "Search"
    Then I should be on a page with title "Search result"
    And I should see "Is this the application you want to link to?"

    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page with title "Do you want to copy the proceedings and merits from L-123-456 to this one?"
    And I should see "You've made a family link"

    When I choose "Yes, the information will be the same"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have a partner?"

    When I click link "Back"
    Then I should be on a page with title "Do you want to copy the proceedings and merits from L-123-456 to this one?"
    And I should not see "You've made a family link"

    When I click link "Back"
    Then I should be on a page with title "Search result"
    And I should see "Is this the application you want to link to?"
    And I should see "L-123-456"

    When I click link "Back"
    Then I should be on a page with title "What is the LAA reference of the application you want to link to?"
    And I should not see "L-123-456"

    When I click link "Back"
    Then I should be on a page with title "Do you want to link this application with another one?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "What does your client want legal aid for?"
