@javascript @vcr
Feature: Loop through proceeding questions

  Background:
    Given I am logged in as a provider
    And I visit the application service
    And I click link "Start"
    Then I choose 'London'
    Then I click 'Save and continue'
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I choose 'No'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
    Then I should be on a page with title "Does your client have a National Insurance number?"
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I should be on a page showing "Has your client applied for civil legal aid before?"
    Then I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "Where should we send your client's correspondence?"
    When I choose "My client's UK home address"
    And I click "Save and continue"
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Use this address'
    And I should be on a page showing "What does your client want legal aid for?"

  Scenario: When provider does not accept default levels of service
    Given I search for proceeding type "Child arrangements order CAO Section 8"
    And I choose a "Child arrangements order (CAO) - residence - appeal - vary" radio button

    When I click 'Save and continue'
    Then I should be on a page with title "Do you want to add another proceeding?"
    And I should be on a page showing "You have added 1 proceeding"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"

    When I choose "Yes"
    And I click 'Save and continue'
    And I search for proceeding type "SE095"
    And I choose "Enforcement order 11J"

    When I click 'Save and continue'
    Then I should be on a page with title "Do you want to add another proceeding?"
    And I should be on a page showing "You have added 2 proceedings"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should be on a page showing "Enforcement order 11J"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Child arrangements order (CAO) - residence - appeal"
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should be on a page showing "What is your client's role in this proceeding?"
    And I should see "Applicant, claimant or petitioner"
    And I should see "Defendant or respondent"
    And I should see "A child subject of the proceeding"
    And I should see "Intervenor"
    And I should see "Joined party"

    When I choose "Applicant, claimant or petitioner"
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Have you used delegated functions for this proceeding?"

    When I choose "Yes"
    And I enter the 'delegated functions on' date of 31 days ago
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "The date you said you used delegated functions is over one month old"
    And I should see "Did you use delegated functions for this proceeding on"

    When I choose "Yes"
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Do you want to use the default level of service and scope for the emergency application?"

    When I choose "No"
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "You cannot change the default level of service for the emergency application for this proceeding"

    When I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "For the emergency application, select the scope"

    When I select "Court of Appeal-final hearing"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Substantive application"
    And I should see "Do you want to use the default level of service and scope for the substantive application?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "You cannot change the default level of service for the substantive application for this proceeding"

    When I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "For the substantive application, select the scope"

    When I select "Court of Appeal-final hearing"
    And I click 'Save and continue'

    Then I should be on a page with title "Enforcement order 11J"
    And I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should be on a page showing "What is your client's role in this proceeding?"

    When I choose "Joined party"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Have you used delegated functions for this proceeding?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Substantive application"
    And I should see "Do you want to use the default level of service and scope for the substantive application?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "For the substantive application, select the level of service"

    When I choose "Family Help (Higher)"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "For the substantive application, select the scope"

    When I select "Blood Tests or DNA Tests"
    And I select "Exchange of Evidence"
    And I click 'Save and continue'

    Then I should be on a page with title "What you're applying for"
    And I should see "What you're applying for"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Client role: Applicant, claimant or petitioner"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Client role: Joined party"

    And I should see "Substantive certificate"
    And I should see "The default substantive cost limit is £25,000"

    And I should see "Cost limits"
    And I should see "Emergency certificate"
    And I should see "The default emergency cost limit is £2,250"
    And I should see "Do you want to request a higher emergency cost limit?"

    When I choose "Yes"
    And I fill "legal-aid-application-emergency-cost-requested-field" with "2,500"
    And I fill "legal-aid-application-emergency-cost-reasons-field" with "because it cost more"

    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"

  Scenario: When provider accepts default levels of service
    Given I search for proceeding type "Child arrangements order CAO Section 8"
    And I choose a "Child arrangements order (CAO) - residence - appeal - vary" radio button

    When I click 'Save and continue'
    Then I should be on a page with title "Do you want to add another proceeding?"
    And I should be on a page showing "You have added 1 proceeding"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"

    When I choose "Yes"
    And I click 'Save and continue'
    And I search for proceeding type "SE095"
    And I choose "Enforcement order 11J"

    When I click 'Save and continue'
    Then I should be on a page with title "Do you want to add another proceeding?"
    And I should be on a page showing "You have added 2 proceedings"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should be on a page showing "Enforcement order 11J"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Child arrangements order (CAO) - residence - appeal"
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should be on a page showing "What is your client's role in this proceeding?"

    When I choose "Applicant, claimant or petitioner"
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Have you used delegated functions for this proceeding?"

    When I choose "Yes"
    And I enter the 'delegated functions on' date of 1 day ago
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Do you want to use the default level of service and scope for the emergency application?"

    When I choose "Yes"
    And I enter the 'hearing date' date of 1 day ago
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1 of 2"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Substantive application"
    And I should see "Do you want to use the default level of service and scope for the substantive application?"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page with title "Enforcement order 11J"
    And I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should be on a page showing "What is your client's role in this proceeding?"

    When I choose "Joined party"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Have you used delegated functions for this proceeding?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 2 of 2"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Substantive application"
    And I should see "Do you want to use the default level of service and scope for the substantive application?"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page with title "What you're applying for"
    And I should see "What you're applying for"
    And I should be on a page showing "Child arrangements order (CAO) - residence - appeal"
    And I should see "Client role: Applicant, claimant or petitioner"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Client role: Joined party"

    And I should see "Substantive certificate"
    And I should see "The default substantive cost limit is £25,000"

    And I should see "Cost limits"
    And I should see "Emergency certificate"
    And I should see "The default emergency cost limit is £2,250"
    And I should see "Do you want to request a higher emergency cost limit?"

    When I choose "Yes"
    And I fill "legal-aid-application-emergency-cost-requested-field" with "2,500"
    And I fill "legal-aid-application-emergency-cost-reasons-field" with "because it cost more"

    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"

  Scenario: No preselected emergency or substantive levels of service
    Given I search for proceeding type "Enforcement order 11J"
    And I choose "Enforcement order 11J"

    When I click 'Save and continue'
    Then I should be on a page with title "Do you want to add another proceeding?"
    And I should be on a page showing "You have added 1 proceeding"
    And I should be on a page showing "Enforcement order 11J"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Enforcement order 11J"
    And I should be on a page showing "What is your client's role in this proceeding?"

    When I choose "Applicant, claimant or petitioner"
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Have you used delegated functions for this proceeding?"

    When I choose "Yes"
    And I enter the 'delegated functions on' date of 1 day ago
    And I click 'Save and continue'
    And I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Do you want to use the default level of service and scope for the emergency application?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "For the emergency application, select the level of service"

    # Test that no checkbox is prefilled
    When I click 'Save and continue'
    Then I should see govuk error summary "Select a level of service"

    When I choose "Family Help (Higher)"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "For the emergency application, select the scope"

    When I select "Blood Tests or DNA Tests"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Do you want to use the default level of service and scope for the substantive application?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "For the substantive application, select the level of service"

    # Test that no checkbox is prefilled
    When I click 'Save and continue'
    Then I should see govuk error summary "Select a level of service"

    When I choose "Full Representation"
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "Has the proceeding been listed for a final contested hearing?"

    When I choose "Yes"
    And I enter the 'date' date of 1 day ago
    And I click 'Save and continue'
    Then I should be on a page showing "Proceeding 1"
    And I should be on a page showing "Enforcement order 11J"
    And I should see "For the substantive application, select the scope"

    When I select "Exchange of Evidence"
    And I click 'Save and continue'
    When I click 'Save and continue'
    Then I should be on a page with title "What you're applying for"
