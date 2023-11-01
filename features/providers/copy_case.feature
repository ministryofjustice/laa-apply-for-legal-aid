Feature: Copy a case's applicable details

Background:
  Given the feature flag for linked_applications is enabled
  And I start the journey as far as the applicant page
  And I have previously created an application with reference "L-TVH-U0T"
  When I enter name 'Test', 'User'
  And I enter the date of birth '03-04-1999'
  When I click 'Save and continue'
  Then I am on the postcode entry page
  When I enter a postcode 'SW1H 9EA'
  And I click find address
  Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
  When I click 'Save and continue'
  Then I should be on a page with title "Do you want to copy an application to this application?"

@javascript @vcr
Scenario: I choose to copy another case's details
  When I choose a 'Yes' radio button
  And I click 'Save and continue'
  Then I should be on a page with title "What is the LAA reference of the application you want to copy?"
  Then I should be on a page showing "You can find this... For example, 'A-BCD-E1F'."
  When I fill "legal-aid-application-search-ref-field" with "L-TVH-U0T"
  And I click 'Search'
  Then I should be on a page with title "Search result"
  And I should be on a page showing "Search result"
  And I should be on a page showing "Do you want to copy L-TVH-U0T to your application?"
  When I choose a 'Yes' radio button
  And I click 'Save and continue'
  Then I should be on a page with title "Does the client have a National Insurance number?"

@javascript @vcr
Scenario: I choose not to copy another case's details
  When I choose a 'No' radio button
  And I click 'Save and continue'
  And I should be on a page with title "What does your client want legal aid for?"
