Feature: Applicant under 16 blocked before or after MTR phase one enabled

  @javascript @vcr
  Scenario: I am instructed to use CCMS when applicant was under 16 on earliest delegated function date
    Given the feature flag for means_test_review_phase_one is disabled
    And I start the journey as far as the applicant page

    When I enter name 'Test', 'Paul'
    And I enter a date of birth that will make me 16 today
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
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'

    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 1 day ago
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    And I should be on a page showing "default substantive cost limit"
    And I should be on a page showing "Do you want to request a higher emergency cost limit?"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"
    When I choose "Yes"
    And I enter national insurance number 'JA293483B'
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page showing "You need to complete this application in CCMS"
    And the page is accessible

  @javascript @vcr
  Scenario: I am NOT instructed to use CCMS when applicant was under 16 on earliest delegated function date
    Given the feature flag for means_test_review_phase_one is enabled
    And I start the journey as far as the applicant page

    When I enter name 'Test', 'Paul'
    And I enter a date of birth that will make me 16 today
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
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'

    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 1 day ago
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    And I should be on a page showing "default substantive cost limit"
    And I should be on a page showing "Do you want to request a higher emergency cost limit?"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"
    When I choose "Yes"
    And I enter national insurance number 'JA293483B'
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page with title "No means test required"
