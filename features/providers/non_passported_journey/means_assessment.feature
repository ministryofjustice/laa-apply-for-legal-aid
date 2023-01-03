Feature: non_passported_journey means assessment
  @javascript
  Scenario: Completes a minimal application for applicant that does not receive benefits
    # Is this test necessary? In this test the client doesnt enter any categories, this is just the standard journey which we are testing
    # extensively elsewhere and it differs significantly from what is below
    Given I start the means application
    Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
    Then I click 'Continue'
    Then I should be on the 'identify_types_of_income' page showing "Which payments does your client receive?"
    Then I select "My client receives none of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client receive student finance?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"
    Then I select "My client makes none of these payments"
    And I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client’s bank accounts"
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
    Then I select "My client has none of these savings or investments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    Then I select "My client has none of these assets"
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
    When I select 'England Infected Blood Support Scheme'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

  @javascript @vcr
  Scenario: Selects and categorises bank transactions into transaction types
    Given I start the merits application with bank transactions with no transaction type category
    Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
    Then I click 'Continue'

    Then I should be on the 'identify_types_of_income' page showing "Which payments does your client receive?"
    Then I select 'Benefits'
    And I select 'Financial help from friends or family'
    And I click 'Save and continue'

    Then I should be on a page with title "Select payments your client receives in cash"
    When I select 'None of the above'
    And I click 'Save and continue'

    Then I should be on a page showing "Does your client receive student finance?"
    When I choose "No"
    And I click 'Save and continue'

    Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"
    Then I select 'Housing'
    And I click 'Save and continue'

    Then I should be on a page with title "Select payments your client makes in cash"
    When I select 'None of the above'
    And I click 'Save and continue'

    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And the following sections should exist:
      | tag | section |
      | h2  | 1. Benefits |
      | h2  | Disregarded benefits |
      | h2  | 2. Financial help from friends or family |

    And I should not see "Housing benefit"

    Then I click the first link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'

    Then I click the '2nd' link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'

    Then I click the '3rd' link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'

    Then I click 'Save and continue'

    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click the first link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'

    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
