Feature: Bank statement upload check your answers
  Background:For a non-passported client truelayer with bank transactions and partner uploaded bank statements journey
    Given csrf is enabled
    And I am logged in as a provider
    And csrf is enabled
    And an applicant named Ida Paisley with a partner has completed their true layer interactions
    And the client has a credit transaction named "babysitting" categorised as friends_or_family
    And the client has a debit transaction named "after school club" categorised as child_care
    And the partner has a how much how often payment categorised as maintenance_in
    And the partner has a how much how often payment categorised as maintenance_out

    When I visit the check income answers page
    Then the "Payments your client gets" section's questions and answers should match:
      | question | answer |
      | Benefits, charitable or government payments | None |
      | Financial help from friends or family | £44.00 |
      | Maintenance payments from a former partner | None |
      | Income from a property or lodger | None |
      | Pension | None |

    And the "Payments the partner gets" section's questions and answers should match:
      | question | answer |
      | Benefits, charitable or government payments | None |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | £50.00 every week |
      | Income from a property or lodger | None |
      | Pension | None |

  @javascript
  Scenario: Viewing client payments
    When I click Check Your Answers Change link for "Payments your client gets"
    Then I should be on a page with title "Which of these payments does your client get?"
    And the checkbox for Financial help from friends or family should be checked
    And the checkbox for Maintenance payments from a former partner should be unchecked

  @javascript
  Scenario: Viewing client outgoings
    When I click Check Your Answers Change link for "Payments your client pays"
    Then I should be on a page with title "Which of these payments does your client pay?"
    And the checkbox for Childcare payments should be checked
    And the checkbox for Maintenance payments to a former partner should be unchecked

  @javascript
  Scenario: Viewing partner payments
    When I click Check Your Answers Change link for "Payments the partner gets"
    Then I should be on the "regular_incomes" page showing "Which of these payments does the partner get?"
    And the checkbox for Financial help from friends or family should be unchecked
    And the checkbox for Maintenance payments from a former partner should be checked

  @javascript
  Scenario: De-selecting and re-selecting client payments
    When I click Check Your Answers Change link for "Payments your client gets"
    Then I should be on a page with title "Which of these payments does your client get?"
    And the checkbox for Financial help from friends or family should be checked

    When I select "My client does not get any of these payments"
    And I click "Save and continue"
    Then I should be on a page with title "Check your answers"
    And the "Payments your client gets" section's questions and answers should match:
      | question | answer |
      | Benefits, charitable or government payments | None |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | None |
      | Income from a property or lodger | None |
      | Pension | None |

    When I click Check Your Answers Change link for "Payments your client gets"
    Then I should be on a page with title "Which of these payments does your client get?"

    When I select "Financial help from friends or family"
    And I click "Save and continue"
    Then I should be on the "cash_income" page showing "Select payments your client gets in cash"

    When I select "My client gets none of these payments in cash"
    And I click "Save and continue"
    Then I should be on the "income_summary" page showing "Sort your client's income into categories"

    When I click link "View statements and add transactions"
    Then I should be on the "incoming_transactions/friends_or_family" page showing "Select payments from friends or family"

    When I select "babysitting"
    And I click "Save and continue"
    Then I should be on the "income_summary" page showing "Sort your client's income into categories"
    And I should see "babysitting"
