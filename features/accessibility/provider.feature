Feature: Provider accessibility
  @javascript
  Scenario: I start a non-passported application and it is accessible
    Given I am logged in as a provider
    When I visit the application service
    Then the page is accessible
    When I click link "Start now"
    Then I should be on the 'providers/applications' page showing 'Your applications'
    And the page is accessible
    When I click link 'Start now'
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    And the page is accessible
    When I click 'Agree and continue'
    Then I should be on a page showing 'Enter your client\'s details'
    And the page is accessible
    Then I enter name 'Test', 'Paul'
    And I enter the date of birth '10-12-1961'
    And I enter national insurance number 'JA293483B'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    And the page is accessible
    Then I enter a postcode 'SW1A 1AA'
    Then I click find address
    Then I select an address 'Buckingham Palace, London, SW1A 1AA'
    Then I click 'Save and continue'
    Then I should be on the 'providers/proceedings' page showing 'S'
    And the page is accessible
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    And the page is accessible
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Covered under a substantive certificate"
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    And the page is accessible

  Scenario: I complete the non-passported means assessment and it is accessible

  Scenario: I complete the passported means assessment and it is accessible

  Scenario: I complete the merits assessment and it is accessible

