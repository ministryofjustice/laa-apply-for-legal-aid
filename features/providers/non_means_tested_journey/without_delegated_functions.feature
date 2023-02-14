Feature: Non-means-tested applicant journey without use of delegation functions

  @javascript @vcr
  Scenario: Completes an application for applicant that is under 18 with MTR phase 1 enabled
    Given the feature flag for means_test_review_phase_one is enabled
    And I am logged in as a provider

    When I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'

    When I click 'Agree and continue'
    Then I should be on the Applicant page

    When I enter name 'Test', 'User'
    And I enter a date of birth that will make me 18 tomorrow
    And I click 'Save and continue'
    Then I am on the postcode entry page

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page showing "What does your client want legal aid for?"

    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Non-molestation order'
    And I should be on a page showing 'Do you want to add another proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client’s role in this proceeding?'

    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
   Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'

    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page with title "What you're applying for"

    When I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number 'CB987654A'
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

    When I click 'Save and continue'
    Then I should be on a page with title "No means test required"
    And I should be on a page showing "You do not need to do a means test as your client is under 18"

    When I click 'Continue'
    Then I should be on a page with title "Provide details of the case"
    And I should be on the 'merits_task_list' page showing 'Latest incident details\nNOT STARTED'

    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    And I enter the 'told' date of 2 days ago
    And I enter the 'occurred' date of 2 days ago

    When I click 'Save and continue'
    Then I should be on a page showing "Opponent's name"
    And I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"

    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    And I choose "Yes"

    When I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I fill "Police notified details" with "Foo bar"
    And I choose option "Application merits task opponent bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"

    When I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    And I should not see "Client received legal help"
    And I should not see "Proceedings currently before court"
    And I fill "Application merits task statement of case statement field" with "Statement of case"

    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success\nNOT STARTED'

    When I click the last link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    And I choose "No"

    When I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    And I choose "Borderline"
    And I fill "Success prospect details" with "Prospects of success"

    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success\nCOMPLETED'

    When I click 'Save and continue'
    Then I should be on a page showing "Check your answers"

    When I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"
    And I check "I confirm the above is correct and that I'll get a signed declaration from my client"

    When I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"
    And I should see 'NON MEANS TESTED'

    When I click 'Submit and continue'
    Then I should be on a page showing "Application complete"

    When I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And I should not see "PASSPORTED"
