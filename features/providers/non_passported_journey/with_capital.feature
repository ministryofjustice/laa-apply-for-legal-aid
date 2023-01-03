Feature: non_passported_journey with capital
  @javascript
  Scenario: Complete an application for applicant that does not receive benefits with no dependants but other values
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
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "How much is your client's home worth?"
    Then I fill "Property value" with "200000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I choose "Yes, a partner or ex-partner"
    Then I click 'Save and continue'
    Then I should be on a page showing "What % share of their home does your client legally own?"
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "What is the estimated value of the vehicle?"
    Then I fill "Estimated value" with "4000"
    And I click "Save and continue"
    Then I should be on a page showing "Are there any payments left on the vehicle?"
    Then I choose "Yes"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "Was the vehicle bought over 3 years ago?"
    Then I choose 'Yes'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "Your client’s bank accounts"
    Then I should be on a page showing "Does your client have any savings accounts they cannot access online?"
    Then I choose 'Yes'
    Then I should be on a page showing "Enter the total amount in all accounts."
    And I fill 'offline savings accounts' with '456.33'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
    Then I select "My client has none of these savings or investments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    Then I select "My client has none of these assets"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is your client prohibited from selling or borrowing against their assets?"
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
    Then I select 'England Infected Blood Support Scheme'
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
