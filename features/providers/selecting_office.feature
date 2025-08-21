Feature: Selecting office

  @javascript @stub_office_schedules_and_user
  Scenario: I am able to select an office
    Given I am logged in as a provider with silas_uuid "51cdbbb4-75d2-48d0-aaac-fa67f013c50a"
    When I visit the select office page
    And I choose '0X395U'
    And I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

  @javascript @stub_office_schedules_and_user
  Scenario: I am unable to select an office that does not exist in PDA
    Given I am logged in as a provider
    Then I visit the select office page
    Then I choose 'A123456'
    Then I click 'Save and continue'
    Then I should be on a page showing 'The office you selected does not have a family contract with the Legal Aid Agency (LAA).'

  @javascript @mock_auth_enabled @vcr_turned_off
  Scenario: I am able to select an office when mock auth is enabled
    Given I am logged in as a provider with silas_uuid "51cdbbb4-75d2-48d0-aaac-fa67f013c50a"
    When I visit the select office page
    And I choose '0X395U'
    And I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

# TODO: Remove or reinstate depending on whether feature is removed/reinstated
#  @javascript @stub_pda_provider_details
#  Scenario: I am able to confirm my office
#    Given I am logged in as a provider
#    Given I have an existing office
#    Then I visit the confirm office page
#    Then I choose 'Yes'
#    Then I click 'Save and continue'
#    Then I should be on a page showing 'Your applications'

# TODO: Remove or reinstate depending on whether feature is removed/reinstated
#  @javascript
#  Scenario: I am able to change my registered office
#    Given I am logged in as a provider
#    Given I have an existing office
#    Then I visit the confirm office page
#    Then I choose 'No'
#    Then I click 'Save and continue'
#    Then I should be on a page showing 'office handling this application'
