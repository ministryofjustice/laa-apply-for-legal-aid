Feature: non_passported_journey with capital
  @javascript
  Scenario: Complete an application for applicant that does not receive benefits with no dependants but other values
    Given I start the means application
    Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
    Then I click 'Continue'
    Then I should be on the 'identify_types_of_income' page showing "Which of these payments does your client get?"
    Then I select "My client does not get any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client get student finance?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"
    Then I select "My client makes none of these payments"
    And I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"
    When I click 'Continue'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's home"
    Then I fill "Property value" with "200000"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I choose "Yes, an ex-partner"
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page with title "Vehicle details"
    And I should see "How much is the vehicle worth?"
    And I should see "Are there any payments left on the vehicle?"
    And I should see "Was the vehicle bought over 3 years ago?"
    And I should see "Is the vehicle in regular use?"
    Then I fill "Estimated value" with "4000"
    And I answer "Are there any payments left on the vehicle?" with "Yes"
    Then I fill "Payment remaining" with "2000"
    And I answer "Was the vehicle bought over 3 years ago?" with "Yes"
    And I answer "Is the vehicle in regular use?" with "Yes"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have any other vehicles?"
    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing "Your client's bank accounts"
    Then I should be on a page showing "Does your client have any savings accounts they cannot access online?"
    Then I choose 'Yes'
    Then I should be on a page showing "Enter the total amount in all accounts."
    And I fill 'offline savings accounts' with '456.33'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
    And I check 'Money not in a bank account'
    Then I fill "savings-amount-cash-field" with "654.33"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    And I check 'Any valuable items worth £500 or more'
    Then I fill "other-assets-declaration-valuable-items-value-field" with "546.33"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client banned from selling or borrowing against their assets?"
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or trusts'
    Then I select 'England Infected Blood Support Scheme'
    Then I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'

  @javascript @vcr
  Scenario: Using the back button to change none_of_these checkboxes
    Given I am checking answers on the check capital answers page
    When I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on the "savings_and_investment" page showing "Which savings or investments does your client have?"
    When I select "None of these savings or investments"
    And I click "Save and continue"
    And I click "Save and continue"
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
    When I click link "Back"
    When I click link "Back"
    Then I should be on the "savings_and_investment" page showing "Which savings or investments does your client have?"
    When I deselect "None of these savings or investments"
    And I click "Save and continue"
    Then I should be on the "savings_and_investment" page showing "Select if your client has any of these savings or investments"
    When I select "None of these savings or investments"
    And I click "Save and continue"
    And I click "Save and continue"
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
    When I click Check Your Answers Change link for 'Other assets'
    Then I should be on the "other_assets" page showing "Which assets does your client have?"
    When I select "None of these assets"
    And I click "Save and continue"
    Then I should be on a page showing "Check your answers"
    When I click link "Back"
    Then I should be on the "other_assets" page showing "Which assets does your client have?"
    When I deselect "None of these assets"
    And I click "Save and continue"
    Then I should be on the "other_assets" page showing "Select if your client has any of these types of assets"
    Then I select "None of these assets"
    Then I click "Save and continue"
    Then I should be on a page showing "Check your answers"
    And I click Check Your Answers Change link for 'policy disregards'
    Then I should be on a page showing 'schemes or trusts'
    Then I select 'None of these schemes or trusts'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the answer for all 'policy disregards' categories should be 'No'
    Then I click Check Your Answers Change link for 'policy disregards'
    And I deselect 'None of these schemes or trusts'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'Select if your client has received any of these payments'
    Then I select "None of these schemes or trusts"
    Then I click "Save and continue"
