Feature: Merits task list

  @javascript @vcr
  Scenario: When the flag is enabled
    Given the feature flag for allow_multiple_proceedings is enabled and method populate of ProceedingType is rerun
    And I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Child arrangements order'
    Then proceeding suggestions has results

  @javascript @vcr
  Scenario: When the flag is disabled
    Given the feature flag for allow_multiple_proceedings is disabled and method populate of ProceedingType is rerun
    And I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I search for proceeding 'Child arrangements order'
    Then proceeding suggestions has no results