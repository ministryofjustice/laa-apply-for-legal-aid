Feature: Adding an SCA Secure Accommodation Order proceeding sets all client_involvement_types to Child

  @javascript @stub_pda_provider_details @vcr @billy
  Scenario: When a provider is adding proceedings and only adds a Secure Accommodation Order
    Given I start the journey as far as the applicant page

    When I enter name 'Test', 'User'
    Then I choose 'No'
    And I enter the date of birth '03-04-1999'
    And I click 'Save and continue'
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

    When I enter a postcode 'SW1H 9EA'
    And I click find address
    And I choose an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    When I click 'Use this address'
    Then I should be on a page showing "Do you want to link this application with another one?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'Child assessment order SCA'
    Then proceeding suggestions has results

    When I choose a 'Child assessment order' radio button
    And I click 'Save and continue'

    Then I should be on the "proceeding_issue_status" page showing "Has this proceeding been issued?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

    When I choose "No"
    And I click 'Save and continue'

    Then I should be on a page with title "Child assessment order"
    And I should see "Respondent"
    And I should see "A child subject of the proceeding"

    When I click link "Back"
    Then I should be on a page showing 'Do you want to add another proceeding?'

    When I choose "Yes"
    And I click 'Save and continue'

    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'secure accommodation order SCA'
    Then proceeding suggestions has results

    When I choose a 'Secure accommodation order' radio button
    And I click 'Save and continue'
    Then I should be on the "proceeding_issue_status" page showing "Has this proceeding been issued?"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the "client_is_child_subject" page showing "Is your client the child subject of this proceeding?"

    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Child assessment order"
    And I should not see "Respondent"
    And I should not see "A child subject of the proceeding"
    And I should see "For special children act, when you apply for a secure accommodation order, your client must be the child subject of this proceeding."
