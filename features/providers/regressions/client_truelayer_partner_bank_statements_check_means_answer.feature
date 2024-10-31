Feature: Bank statement upload check your answers
  @javascript
  Scenario: For a non-passported client truelayer with bank transactions and partner uploaded bank statements journey
    Given csrf is enabled
    And I am logged in as a provider
    And csrf is enabled
    And an applicant named Ida Paisley with a partner has completed their true layer interactions
    And the client has a transaction named "babysitting" categorised as "Financial help from friends or family"
    And the partner has a how much how many payment categorised as "Maintenance payments from a former partner"

    When I visit the check income answers page
    And the "Payments your client receives" section's questions and answers should match:
      | question | answer |
      | Benefits, charitable or government payments | None |
      | Financial help from friends or family | £44.00 |
      | Maintenance payments from a former partner | None |
      | Income from a property or lodger | None |
      | Pension | None |

    And the "Payments the partner receives" section's questions and answers should match:
      | question | answer |
      | Benefits, charitable or government payments | None |
      | Financial help from friends or family | None |
      | Maintenance payments from a former partner | £50.00\nEvery week |
      | Income from a property or lodger | None |
      | Pension | None |

    When I click Check Your Answers Change link for "payments your client receives"
    Then I should be on a page with title "Which of these payments does your client get?"
    And the checkbox for Financial help from friends or family should be checked
    And the checkbox for Maintenance payments from a former partner should be unchecked
