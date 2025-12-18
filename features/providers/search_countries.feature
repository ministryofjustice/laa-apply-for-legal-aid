@EjectCassetteAfterScenario
Feature: Search countries

Background: User is on existing opponent organisation search page
  Given I insert cassette "lfa_countries_all"
  And I complete the passported journey as far as check your answers with an overseas address
  When I click Check Your Answers Change link for "home address"
  Then I should be on a page with title "Find your client's home address"
  And I click link "Enter a non-UK address"

@javascript @billy
Scenario: No results returned is seen on screen when non-existent country search entered
  When I search for country "cake"
  Then the country result list on page returns a "No results found." message
  And country suggestions has 0 results

@javascript @billy
Scenario: I am able to find a single country using a partial word
  When I search for country "fra"
  Then the country suggestions include "France"
  And country suggestions has 1 result

@javascript @billy
Scenario: I am able to find multiple countries using a partial word
  When I search for country "gree"
  Then the country suggestions include "Greenland"
  And the country suggestions include "Greece"
  And country suggestions has 2 results

@javascript @billy
Scenario: I am able to clear the country search terms
  When I search for country "fra"
  Then the country suggestions include "France"
  When I click link "Clear search"
  Then country search field is empty
  And country suggestions has 0 results
  When I click "Save and continue"
  Then I should see govuk error summary "Search for and select a country"

@javascript
Scenario: I am unable to proceed without selecting a country
  When I click "Save and continue"
  Then I should be on a page with title "Enter your client's overseas home address"
  Then I should see govuk error summary "Search for and select a country"
