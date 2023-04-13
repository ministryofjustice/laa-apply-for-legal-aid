Feature: partner_means_assessment with an unknown address
  @javascript @vcr
  Scenario: I am able to add a partner with a different address from the applicant
    Given I start the journey as far as the applicant page
    And the feature flag for partner_means_assessment is enabled
    And a "bank holiday" exists in the database

    When I enter name 'Test', 'Walker'
    And I enter the date of birth '10-1-1980'
    And I click 'Save and continue'
    Then I should be on a page with title "Enter your client's correspondence address"

    When I enter a postcode 'SW1H 9EA'
    And I click "Find address"
    And I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page showing "What does your client want legal aid for?"

    When I search for proceeding 'Non-molestation order'
    And proceeding suggestions has results
    And I choose a 'Non-molestation order' radio button
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

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
    Then I should be on a page showing "What you're applying for"

    When I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "Yes"
    And I enter national insurance number "JA123456D"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have a partner?"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page with title "Enter the partner's details"

    When I enter name 'Test', 'Partner'
    And I enter the date of birth '10-1-1990'
    And I choose "Yes"
    And I enter national insurance number "JA123456D"
    And I click 'Save and continue'
    Then I should be on a page with title "Is the partner's correspondence address the same as your client's?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Enter the partner's correspondence address"

    When I enter a postcode 'SW1A 3AA'
    And I click "Find address"
    Then I should be on a page with title "Enter the partner's correspondence address"

    When I enter address line one "One any street"
    And I enter city "Any Town"
    When I click 'Save and come back later'
    Then I should be on a page with title "Applications"

    When I view the first application in the table
    Then I should be on a page with title "Enter the partner's correspondence address"

    When I click 'Save and continue'
    Then I should be on a page with title "Check your answers"
