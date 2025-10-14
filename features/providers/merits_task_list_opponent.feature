Feature: Merits task list opponent

  Background:
    Given I have completed a non-passported application and reached the merits task_list
    Then I should be on the 'merits_task_list' page showing 'Opponents Not started'
    When I click link 'Opponents'
    Then I should be on a page showing "Is the opponent an individual or an organisation?"

  @javascript
  Scenario: I add an opponent individual
    When I choose a 'An individual' radio button
    Then I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "You have added 1 opponent"
    And  I should be on a page showing "John Doe"
    When I choose a 'No' radio button
    And I click 'Save and continue'
    Then I should be on a page showing "Latest incident details"

  @javascript @vcr @billy
  Scenario: I add an opponent existing organisation
    When I choose a 'An organisation' radio button
    Then I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    When I search for organisation "bab"
    Then the organisation suggestions include "Babergh District Council\nLocal Authority"
    And I choose a 'Babergh District Council' radio button
    When I click 'Save and continue'
    Then I should be on a page showing "You have added 1 opponent"
    And  I should be on a page showing "Babergh District Council Local Authority"
    When I choose a 'No' radio button
    And I click 'Save and continue'
    Then I should be on a page showing "Latest incident details"

  @javascript @vcr
  Scenario: I add an opponent new organisation
    When I choose a 'An organisation' radio button
    Then I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    And I click link "I cannot find the organisation"
    Then I should be on a page with title "Opponent"
    When I fill "application-merits-task-opponent-name-field" with "My Organisation"
    And I select an organisation type "Sole Trader" from the list
    And I click 'Save and continue'
    Then I should be on a page showing "You have added 1 opponent"
    And  I should be on a page showing "My Organisation Sole Trader"
    When I choose a 'No' radio button
    When I click 'Save and continue'
    Then I should be on a page showing "Latest incident details"
