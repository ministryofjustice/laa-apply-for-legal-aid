Feature: Linking one application to another application

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
  Then I should be on a page with title "Do you want to copy an application to your current application?"

@javascript @vcr
Scenario: I choose to link another case's details when a copy has not been made
  When I choose a 'No' radio button
  And I click 'Save and continue'
  And I should be on a page with title "Do you want to link an application to your application?"

  When I choose a 'Yes' radio button
  And I click 'Save and continue'
  Then I should be on a page with title "What is the LAA reference of the application you want to link to?"

  When I fill "linked-application-search-ref-field" with "L-TVH-U0T"
  And I click 'Search'
  Then I should be on a page with title "Link cases"

  When I choose a "Yes, there's a family link" radio button
  And I click "Save and continue"
  Then I should be on a page with title "Does the client have a National Insurance number?"

@javascript @vcr
Scenario: I choose to link another case's details when a copy has been made
  When I choose a 'Yes' radio button
  And I click 'Save and continue'
  Then I should be on a page with title "What is the LAA reference of the application you want to copy?"
  
  When I fill "legal-aid-application-search-ref-field" with "L-TVH-U0T"
  When I click 'Search'
  Then I should be on a page with title "Search result"

  When I choose a 'Yes' radio button
  And I click 'Save and continue'
  Then I should be on a page with title "Link cases"

  When I choose a "Yes, there's a family link" radio button
  And I click "Save and continue"
  Then I should be on a page with title "Does the client have a National Insurance number?"

@javascript @vcr
Scenario: I choose not to link another case's details
  When I choose a 'No' radio button
  And I click 'Save and continue'
  Then I should be on a page with title "Do you want to link an application to your application?"

  When I choose a "No" radio button
  And I click "Save and continue"
  Then I should be on a page with title "What does your client want legal aid for?"