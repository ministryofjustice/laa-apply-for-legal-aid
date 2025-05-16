Feature: Search proceedings

@javascript @vcr
  Scenario: No results returned is seen on screen when invalid proceeding search entered
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Sign in"
    Then I choose 'London'
    Then I click 'Save and continue'
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'No'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
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
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding type "cakes"
    Then the proceeding type result list on page returns a "No results found." message

  @javascript @vcr
  Scenario: I am able to clear proceeding on the proceeding page
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Sign in"
    Then I choose 'London'
    Then I click 'Save and continue'
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'No'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
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
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"
    And I search for proceeding 'dom'
    Then proceeding suggestions has results
    When I click clear search
    Then the results section is empty
    Then proceeding search field is empty
