Feature: Non-means-tested applicant journeys

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

    # TODO: under 18s are not applicable to domestic abuse applications, only section 8 but these are not enabled at time of writing
    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Non-molestation order'
    And I should be on a page showing 'Do you want to add another proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'

    When I select 'I have not used delegated functions'
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
    And I should be on a page showing "No means test required as client is under 18"

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
    Then I should be on a page showing "Does the opponent have the mental capacity to understand the terms of a court order?"
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
    And I select the first checkbox

    When I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"

    When I click 'Submit and continue'
    Then I should be on a page showing "Application complete"

    When I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And I should not see "PASSPORTED"

  @javascript @vcr
  Scenario: Completes a minimal application for applicant that was under 18 at time of earliest delegated function with MTR phase 1 enabled
    Given the feature flag for means_test_review_phase_one is enabled
    And I am logged in as a provider

    When I visit the application service
    And I click link "Start"
    And I click link "Make a new application"
    Then I should be on the 'providers/declaration' page showing 'Declaration'

    When I click 'Agree and continue'
    Then I should be on the Applicant page

    When I enter name 'Test', 'User'
    And I enter a date of birth that will make me 18 today
    And I click 'Save and continue'
    Then I am on the postcode entry page

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page showing "What does your client want legal aid for?"

    # TODO: under 18s are not applicable to domestic abuse applications, only section 8 but these are not enabled at time of writing
    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Non-molestation order'
    And I should be on a page showing 'Do you want to add another proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'

    When I select 'Non-molestation order'
    And I enter the 'nonmolestation order used delegated functions on' date of 1 day ago
    And I click 'Save and continue'
    Then I should be on a page with title "What you're applying for"
    And I should see 'Do you want to request a higher emergency cost limit?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number 'CB987654A'
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

    When I click 'Save and continue'
    Then I should be on a page with title "No means test required"
    And I should be on a page showing "You do no need to do a means test as your client was under 18 when you first used delegated functions on this case"

    When I click 'Continue'
    Then I should be on a page with title "Provide details of the case"

  @javascript @vcr
  Scenario: Completes a minimal application for applicant that is under 18 without MTR phase 1 enabled
    Given I am logged in as a provider

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

    # TODO under 18s are not applicable to domestic abuse applications, only section 8 but these are not enabled at time of writing
    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Non-molestation order'
    And I should be on a page showing 'Do you want to add another proceeding?'

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing 'Which proceedings have you used delegated functions for?'

    When I select 'I have not used delegated functions'
    And I click 'Save and continue'
    Then I should be on a page with title "What you're applying for"

    When I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number 'CB987654A'
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

    When I click 'Save and continue'
    And I should be on a page showing "DWP records show that your client does not receive a passporting benefit – is this correct?"
