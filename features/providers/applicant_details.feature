Feature: Applicant details
  @javascript @vcr @billy
  Scenario: Completes the application using address lookup with multiple proceedings
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'Yes'
    Then I enter last name at birth 'Smith'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 1 proceeding'
    Then I should be on a page showing 'Non-molestation order'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Search for legal proceedings'
    Then I search for proceeding 'injunction'
    Then proceeding suggestions has results
    Then I should be on a page showing 'Harassment - injunction'
    And I should be on a page not showing 'Non-molestation order'
    Then I search for proceeding 'Occupation order'
    Then proceeding suggestions has results
    Then I choose a 'Occupation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 2 proceedings'
    Then I should be on a page showing 'Non-molestation order'
    Then I should be on a page showing 'Occupation order'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I click the first link 'Remove'
    Then I click the first link 'Remove'
    Then I should be on a page showing 'Search for legal proceedings'
    Then I search for proceeding 'FGM Protection Order'
    Then proceeding suggestions has results
    Then I choose a 'FGM Protection Order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 1 proceeding'
    Then I should be on a page showing 'FGM Protection Order'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I search for proceeding 'Occupation order'
    Then proceeding suggestions has results
    Then I choose a 'Occupation order' radio button
    Then I click 'Save and continue'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I search for proceeding 'Harassment - injunction'
    Then proceeding suggestions has results
    Then I choose a 'Harassment - injunction' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'You have added 3 proceedings'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nFGM Protection Order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nFGM Protection Order\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 2 days ago
    When I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nFGM Protection Order'
    And I should see 'Do you want to use the default level of service and scope for the emergency application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 3\nFGM Protection Order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 3\nOccupation order\nWhat is your client's role in this proceeding?'
    When I choose 'Defendant or respondent'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 3\nOccupation order\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 35 days ago
    When I click 'Save and continue'
    Then I should see 'Proceeding 2 of 3\nOccupation order\n!\nWarning\nThe date you said you used delegated functions is over one month old.\nDid you use delegated functions for this proceeding'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 3\nOccupation order'
    And I should see 'Do you want to use the default level of service and scope for the emergency application?'
    When I choose 'Yes'
    And I enter the 'proceeding hearing date' date of 1 month in the future
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 3\nOccupation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 3 of 3\nHarassment - injunction\nWhat is your client's role in this proceeding?'
    When I choose 'Defendant or respondent'
    And I click 'Save and continue'
    Then I should see 'Proceeding 3 of 3\nHarassment - injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    When I click 'Save and continue'
    Then I should see 'Proceeding 3 of 3\nHarassment - injunction'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing 'Occupation order'
    Then I should be on a page showing 'Harassment - injunction'
    Then I should be on a page showing 'Emergency certificate'
    Then I should be on a page showing 'Substantive certificate'
    Then I should be on a page showing "Do you want to request a higher emergency cost limit?"
    When I choose 'Yes'
    And I enter a emergency cost requested '5000'
    And I enter legal aid application emergency cost reasons field 'This is why I require extra funding'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Proceeding 1 FGM Protection Order'
    Then I should be on a page showing 'Proceeding 2 Occupation order'
    Then I should be on a page showing 'Proceeding 3 Harassment - injunction'
    Then I should not see 'Legal Aid, Sentencing and Punishment of Offenders Act'
    Then I should be on a page showing 'FGM Protection Order proceeding details'
    Then I should be on a page showing 'Harassment - injunction proceeding details'
    Then I should be on a page showing 'Occupation order proceeding details'
    Then I should be on a page showing 'Delegated functions Not used'
    Then I should be on a page showing 'Delegated functions' with a date of 2 days ago using '%-d %B %Y' format
    Then I should be on a page showing 'Delegated functions' with a date of 35 days ago using '%-d %B %Y' format

  @javascript @vcr @billy
  Scenario: Completes the application using address lookup
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'No'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    When I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you need to do"
    When I click 'Continue'
    And I should be on a page showing "What is your client's employment status?"
    And I select "None of the above"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client use online banking?"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title "Share bank statements with online banking"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title "Enter your client's email address"
    Then I should be on a page showing "We'll use this to send your client a link to the service."
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I click 'Send link'
    Then I am on the application confirmation page

  @javascript @vcr @billy
  Scenario: Completes the application using address lookup with building number name
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'No'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    And I enter a building number name '100'
    Then I click find address
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"

  @javascript @vcr @billy
  Scenario: Completes the application using manual address
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'No'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'XX1 1XX'
    Then I click find address
    Then I click link "Enter an address manually"
    Then I enter address line one 'Fake Road'
    Then I enter city 'Fake City'
    Then I enter postcode 'XX1 1XX'
    Then I click 'Save and continue'
    And I should be on a page showing "What does your client want legal aid for?"
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I search for proceeding 'Child arrangements'
    Then I choose a 'Child arrangements order (residence)' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(residence\)\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(residence\)\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    When I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(residence\)'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you need to do"
    When I click 'Continue'
    And I should be on a page showing "What is your client's employment status?"
    And I select "None of the above"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client use online banking?"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title "Share bank statements with online banking"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title "Enter your client's email address"
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I click 'Send link'
    Then I am on the application confirmation page

  @javascript @vcr @billy
  Scenario: I can see that the applicant receives benefits
    Given I start the journey as far as the applicant page
    And a "bank holiday" exists in the database
    Then I enter name 'Test', 'Walker'
    Then I choose 'No'
    Then I enter the date of birth '10-1-1980'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 35 days ago
    When I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\n!\nWarning\nThe date you said you used delegated functions is over one month old.\nDid you use delegated functions for this proceeding'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the emergency application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    And I should be on a page showing "Emergency certificate"
    And I should be on a page showing "default substantive cost limit"
    Then I choose 'Yes'
    And I enter a emergency cost requested '5000'
    And I enter legal aid application emergency cost reasons field 'This is why I require extra funding'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'JA293483A'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client receives a passporting benefit'

  @javascript @vcr @billy
  Scenario: I can see that the applicant does not receive benefits
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Paul'
    Then I choose 'No'
    Then I enter the date of birth '10-12-1961'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    When I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "default substantive cost limit"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'JA293483B'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"
    And I choose "No"
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit"

  @javascript @vcr
  Scenario: I want to change client details after a failed benefit check
    Given I start the application with a negative benefit check result
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit"
    Then I choose 'No, my client gets a passporting benefit'
    Then I click "Save and continue"
    Then I should be on a page showing "Check your client's details"
    Then I click the first link 'Client name'
    Then I should be on a page showing "Enter your client's details"
    Then I enter name 'Kyle', 'Walker'
    Then I choose 'No'
    Then I enter the date of birth '10-1-1980'
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'JA293483A'
    When I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client receives a passporting benefit"

  @javascript @vcr @billy
  Scenario: Allows return to, and proceed from, Delegated Function date view
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'No'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 5 days ago
    When I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the emergency application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
