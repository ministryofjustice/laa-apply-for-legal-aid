Feature: Selecting office

  @javascript @stub_pda_provider_details
  Scenario: I am able to select an office
    Given I am logged in as a provider
    Then I visit the select office page
    Then I choose 'London'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

  @javascript @stub_pda_provider_details
  Scenario: I am able to confirm my office
    Given I am logged in as a provider
    Given I have an existing office
    Then I visit the confirm office page
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

  @javascript
  Scenario: I am able to change my registered office
    Given I am logged in as a provider
    Given I have an existing office
    Then I visit the confirm office page
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'office handling this application'
