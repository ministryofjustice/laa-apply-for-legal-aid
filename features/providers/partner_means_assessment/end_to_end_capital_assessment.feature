Feature: partner_means_assessment full journey
  @javascript
  Scenario: I am able to complete a minimal (answering no to everything) capital means assessment with a partner
    Given csrf is enabled
    And I have completed a non-passported employed application for "client and partner" with bank statements as far as the end of the means income section
    Then I should be on a page showing "Check your answers"

    When I click "Save and continue"
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client and their partner's capital"

    When I click "Continue"
    Then I should be on a page with title "Does your client or their partner own the home your client usually lives in?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client or their partner own a vehicle?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Which bank accounts do your client and their partner have?"
    And the following sections should exist:
      | tag | section |
      | h2  | Your client's offline accounts |
      | h2  | The partner's offline accounts |
      | h2  | Joint accounts |

    When I select "Current account" in "client accounts"
    And I fill 'offline_current_accounts' with '111.99'
    When I select "Savings account" in "partner accounts"
    And I fill 'offline_savings_accounts' with '222.99'
    When I select "Current account" in "joint accounts"
    And I fill 'joint_offline_current_accounts' with '333.99'
    And I click "Save and continue"
    Then I should be on a page with title "Which savings or investments does either your client or their partner have?"

    When I select "None of these savings or investments"
    And I click "Save and continue"
    Then I should be on a page with title "Which assets does either your client or their partner have?"

    When I select "None of these assets"
    And I click "Save and continue"
    Then I should be on a page with title "Is your client or their partner banned from selling or borrowing against their assets?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "Disregarded payments"

    When I check "My client or their partner has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"

    When I check "My client or their partner has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

  @javascript
  Scenario: I am able to complete the capital means assessment for a client with a partner
    Given csrf is enabled
    And I have completed a non-passported employed application for "client and partner" with bank statements as far as the end of the means income section
    Then I should be on a page showing "Check your answers"

    When I click "Save and continue"
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client and their partner's capital"

    When I click "Continue"
    Then I should be on a page with title "Does your client or their partner own the home your client usually lives in?"

    Then I choose "Yes, with a mortgage or loan"
    Then I click "Save and continue"
    Then I should be on a page showing "Your client's home"

    Then I fill "Property value" with "200000"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I choose "Yes, an ex-partner"
    Then I fill "Percentage home" with "50"
    Then I click "Save and continue"
    Then I should be on a page with title "Does your client or their partner own a vehicle?"

    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page with title "Vehicle details"

    When I answer "Who owns the vehicle?" with "My client and their partner"
    And I fill "Estimated value" with "4000"
    And I answer "Are there any payments left on the vehicle?" with "Yes"
    And I fill "Payment remaining" with "2000"
    And I answer "Was the vehicle bought over 3 years ago?" with "Yes"
    And I answer "Is the vehicle in regular use?" with "Yes"
    And I click "Save and continue"
    Then I should be on a page with title 'Does your client or their partner have any other vehicles?'

    When I choose 'No'
    And I click "Save and continue"
    Then I should be on a page with title "Which bank accounts do your client and their partner have?"

    When I select "None of these"
    And I click "Save and continue"
    Then I should be on a page with title "Which savings or investments does either your client or their partner have?"

    When I check "Money not in a bank account"
    And I fill "savings-amount-cash-field" with "4000"
    And I click "Save and continue"
    Then I should be on a page with title "Which assets does either your client or their partner have?"

    When I select "Land"
    And I fill "land_value" with "20,000"
    And I click "Save and continue"
    Then I should be on a page with title "Is your client or their partner banned from selling or borrowing against their assets?"

    When I choose "Yes"
    And I fill "restrictions_details" with "Some details of restrictions"
    And I click "Save and continue"
    Then I should be on a page showing "Disregarded payments"

    When I check "My client or their partner has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"

    When I check "My client or their partner has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"
