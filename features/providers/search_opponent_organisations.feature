@EjectCassetteAfterScenario
Feature: Search existing opponent organisations

Background: User is on existing opponent organisation search page
  Given I insert cassette "lfa_organisations_all"
  When I have completed a non-passported application and reached the merits task_list
  Then I should be on the 'merits_task_list' page showing 'Opponents\nNOT STARTED'
  When I click link 'Opponents'
  Then I should be on a page showing "Is the opponent an individual or an organisation?"
  When I choose a 'An organisation' radio button
  And I click 'Save and continue'
  Then I should be on a page with title "Opponent"

@javascript @billy
Scenario: No results returned is seen on screen when non-existant organisation search entered
  When I search for non-existent organisation
  Then the organisation result list on page returns a "No results found." message
  And organisation suggestions has 0 results

@javascript @billy
Scenario: I am able to find a single organisation using a partial word
  When I search for organisation "bab"
  Then the organisation suggestions include "Babergh District Council\nLocal Authority"
  And organisation suggestions has 1 result

@javascript @billy
Scenario: I am able to find multiple organisations using a partial word
  When I search for organisation "ang"
  Then the organisation suggestions include "Isle of Anglesey County Council\nLocal Authority"
  And the organisation suggestions include "Angus Council\nLocal Authority"
  And organisation suggestions has 2 results

@javascript @billy
Scenario: I am able to see highlighted search terms in the results
  When I search for organisation "ang loc"
  Then the organisation suggestions include "Isle of Anglesey County Council\nLocal Authority"
  And the organisation suggestions include "Angus Council\nLocal Authority"
  And organisation suggestions has 2 results
  And I can see the highlighted search term "Angus" 1 time
  And I can see the highlighted search term "Anglesey" 1 time
  And I can see the highlighted search term "Local" 2 times

# NOTE: previous javascript highlighting incarnations could result in html output to the screen, this is no longer
# possible using the full text search "headline" method, so the scenario's original purpose is no longer applicable.
# It does, howver, excercise a search edge case so may be of value?!
@javascript @billy
Scenario: I am prevented from seeing HTML output in search results
  When I search for organisation "prison r"
  Then the organisation suggestions include "Risley\nHM Prison or Young Offender Institute"
  Then the organisation suggestions include "Ranby\nHM Prison or Young Offender Institute"
  Then the organisation suggestions include "Rye Hill\nHM Prison or Young Offender Institute"
  And organisation suggestions has 3 results
  And I can see the highlighted search term "Risley" 1 time
  And I can see the highlighted search term "Ranby" 1 time
  And I can see the highlighted search term "Rye" 1 time
  And I can see the highlighted search term "Prison" 3 times

  @javascript @billy
  Scenario: I am able to clear the organisation search terms
    When I search for organisation "bab"
    Then the organisation suggestions include "Babergh District Council\nLocal Authority"
    When I click link "Clear search"
    Then organisation search field is empty
    And organisation suggestions has 0 results
    When I click "Save and continue"
    Then I should see govuk error summary "Search for and select an organisation"

  @javascript
  Scenario: I am unable to proceed without selecting an organisation
    When I click "Save and continue"
    Then I should be on a page with title "Opponent"
    Then I should see govuk error summary "Search for and select an organisation"
