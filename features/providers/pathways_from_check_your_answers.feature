Feature: Pathways from check your answers

  @javascript @vcr
  Scenario: I do not use delegated functions
    Given I complete the journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'must complete a financial assessment'
    Then I click 'Continue'
    Then I should be on a page showing 'Does your client use online banking?'

  @javascript @vcr
  Scenario: I do not use delegated functions for a passported journey
    Given I complete the passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'
    Then I click 'Continue'
    Then I should be on a page showing "You'll need to tell us if your client"

  @javascript @vcr
  Scenario: I use delegated functions and will return later
    Given I complete the journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing 'must complete a financial assessment'
    Then I click 'Continue'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "You told us you've used delegated functions"
    Then I click link 'Back to your applications'
    Then I should be on a page showing 'Your applications'

  @javascript @vcr
  Scenario: I use delegated functions and a substantive application
    Given I complete the journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing 'must complete a financial assessment'
    Then I click 'Continue'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Does your client use online banking?'

  @javascript @vcr
  Scenario: I use delegated functions and a substantive application for a passported journey
    Given I complete the passported journey as far as check your answers
    And a "bank holiday" exists in the database
    And I used delegated functions
    Then I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'
    Then I click 'continue_button'
    Then I should be on a page showing 'Do you want to make a substantive application now?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "You'll need to tell us if your client"
