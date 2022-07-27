Feature: Bank statement flow

  @javascript
  Scenario: Bank statement upload permissions flow
    Given csrf is enabled
    And I have completed a non-passported employed application and reached the open banking consent with bank statement upload enabled
    And I should be on a page showing "Does your client use online banking?"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Upload bank statements"
    And the page is accessible

    Given I upload the fixture file named 'acceptable.pdf'
    And I upload an evidence file named 'hello_world.pdf'
    When I click 'Save and continue'
    Then I should be on a page with title "HMRC has no record of your client's employment in the last 3 months"

    When I fill "legal-aid-application-full-employment-details-field" with "Applicant also earns 50 gbp, some extra details about employment"
    And I click 'Save and continue'
    Then I should be on a page with title "Which payments does your client receive?"

    When I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page with title "Select payments your client receives in cash"

    When I select 'None of the above'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client receive student finance?"

    When I choose "Yes"
    And I enter amount '5000'
    And I click 'Save and continue'
    Then I should be on a page with title "Which payments does your client make?"

    When I check "Housing payments"
    And I click 'Save and continue'
    Then I should be on a page with title "Select payments your client makes in cash"

    When I select 'Housing payments'
    But I select 'None of the above'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client own the home that they live in?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client own a vehicle?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Which savings or investments does your client have?"

    When I select "Money not in a bank account"
    And I fill "Cash" with "10000"
    And I click 'Save and continue'
    Then I should be on a page with title "Which assets does your client have?"

    When I select 'My client has none of these assets'
    And I click 'Save and continue'
    Then I should be on a page with title "Is your client prohibited from selling or borrowing against their assets?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Select if your client has received payments from these schemes or charities"

    When I select 'England Infected Blood Support Scheme'
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"
