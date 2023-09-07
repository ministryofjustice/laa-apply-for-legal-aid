Feature: Search existing opponent organisations

Background: User is on existing opponent organisation search page
  Given the feature flag for opponent_organisations is enabled
  When I have completed a non-passported application and reached the merits task_list
  Then I should be on the 'merits_task_list' page showing 'Opponents\nNOT STARTED'
  When I click link 'Opponents'
  Then I should be on a page showing "Is the opponent an individual or an organisation?"
  When I choose a 'An organisation' radio button
  And I click 'Save and continue'
  Then I should be on a page showing "Which organisation is an opponent in the case?"

@javascript @vcr
Scenario: No results returned is seen on screen when non-existant organisation search entered
  When I search for organisation "cakes"
  Then the organisation result list on page returns a "No results found." message
  And organisation suggestions has 0 results

@javascript @vcr
Scenario: I am able to find a single organisation using a partial word
  When I search for organisation "bab"
  Then the organisation suggestions include "Babergh District Council\nLocal Authority"
  And organisation suggestions has 1 result

@javascript @vcr
Scenario: I am able to find multiple organisations using a partial word
  When I search for organisation "ang"
  Then the organisation suggestions include "Isle of Anglesey County Council\nLocal Authority"
  And the organisation suggestions include "Angus Council\nLocal Authority"
  And organisation suggestions has 2 results

@javascript @vcr
Scenario: I am able to see highlighted search terms in the results
  When I search for organisation "coun ang local"
  Then the organisation suggestions include "Isle of Anglesey County Council\nLocal Authority"
  And the organisation suggestions include "Angus Council\nLocal Authority"
  And organisation suggestions has 2 results
  And I can see the highlighted search term "Ang" 2 times
  And I can see the highlighted search term "Coun" 3 times
  And I can see the highlighted search term "Local" 2 times

  @javascript @vcr
  Scenario: I am able to clear the organisation search terms
    When I search for organisation "bab"
    Then the organisation suggestions include "Babergh District Council\nLocal Authority"
    When I click link "Clear search"
    Then organisation search field is empty
    And organisation suggestions has 0 results
