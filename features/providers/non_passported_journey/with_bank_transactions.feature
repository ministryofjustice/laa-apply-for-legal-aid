Feature: non_passported_journey with bank transactions
  @javascript @vcr
  Scenario: Selects and categorises bank transactions into transaction types
    Given I start the merits application with bank transactions with no transaction type category
    Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
    Then I click 'Continue'

    Then I should be on the 'identify_types_of_income' page showing "Which of these payments does your client get?"
    Then I select 'Pension'
    And I select 'Financial help from friends or family'
    And I click 'Save and continue'

    Then I should be on a page with title "Select payments your client receives in cash"
    When I select 'My client receives none of these payments in cash'
    And I click 'Save and continue'

    Then I should be on a page showing "Does your client get student finance?"
    When I choose "No"
    And I click 'Save and continue'

    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"
    Then I select 'Housing'
    And I click 'Save and continue'

    Then I should be on a page with title "Select payments your client pays in cash"
    When I select 'None of the above'
    And I click 'Save and continue'

    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And the following sections should exist:
      | tag | section |
      | h2  | 1. Financial help from friends or family |
      | h2  | 2. Pension |

    And I should not see "Housing benefit"

    Then I click the first link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'

    Then I click the '2nd' link 'View statements and add transactions'
    And I should see govuk-tag "Financial help"
    Then I select the first checkbox
    And I click 'Save and continue'

    Then I click the '2nd' link 'View statements and add transactions'
    And I should see govuk-tag "Financial help"
    And I should see govuk-tag "Pension"
    Then I click 'Save and continue'

    Then I click 'Save and continue'

    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click the first link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'

    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
