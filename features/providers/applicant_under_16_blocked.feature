Feature: Applicant under 16 blocked

  @javascript @vcr
  Scenario: I am instructed to use CCMS when applicant was under 16 on earliest delegated function date
    Given I start the journey as far as the applicant page

    When I enter name 'Test', 'Paul'
    Then I choose 'No'
    And I enter a date of birth that will make me 16 today
    And I click 'Save and continue'
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
    And I click 'Use this address'
    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'

    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 1 day ago
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
    And I should be on a page showing "default substantive cost limit"
    And I should be on a page showing "Do you want to request a higher emergency cost limit?"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    When I choose "Yes"
    And I enter national insurance number 'JA293483B'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page showing "You need to apply using CCMS"

  @javascript
  Scenario: I am warned not to use the service for under 16 year olds
    Given I visit the application service
    When I should be on a page with title "Apply for legal aid"
    Then I should see "But do not use this service if:"
    And I should see "the client is under 16 years old"
