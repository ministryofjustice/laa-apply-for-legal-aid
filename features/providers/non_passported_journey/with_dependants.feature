Feature: non_passported_journey with dependants
  @javascript
  Scenario: Complete an application for an applicant that does not receive benefits with dependants
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
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I add the details for a child dependant
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I fill "Name" with "Pugsley Adams"
    And I enter a date of birth for a 21 year old
    And I choose "Child dependant"
    And I choose option "dependant-in-full-time-education-true-field"
    And I choose option "dependant-has-income-true-field"
    And I fill "monthly income" with "1234"
    And I choose option "dependant-has-assets-more-than-threshold-field"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I fill "Name" with "Granny Addams"
    And I enter a date of birth for a 80 year old
    When I choose "Adult dependant"
    And I choose option "dependant-in-full-time-education-field"
    And I choose option "dependant-has-income-true-field"
    And I fill "monthly income" with "4321"
    And I choose option "dependant-has-assets-more-than-threshold-true-field"
    And I fill "assets value" with "8765"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"
    When I click 'Continue'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's bank accounts"
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
    Then I select "None of these savings or investments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    Then I select "None of these assets"
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or trusts'
    When I select 'England Infected Blood Support Scheme'
    And I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'

  @javascript
  Scenario: Complete a merits application for applicant that does not receive benefits with a child dependant
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
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I fill "Name" with "Wednesday Adams"
    And I enter a date of birth for a 14 year old
    And I choose "Child dependant"
    And I choose option "dependant-in-full-time-education-field"
    And I choose option "dependant-has-income-field"
    And I choose option "dependant-has-assets-more-than-threshold-field"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I fill "Name" with "Pugsley Addams"
    And I enter a date of birth for a 10 year old
    And I choose "Child dependant"
    And I choose option "dependant-in-full-time-education-field"
    And I choose option "dependant-has-income-field"
    And I choose option "dependant-has-assets-more-than-threshold-field"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    And I should see 'Pugsley Addams'
    When I click has other dependants remove link for dependant '2'
    Then I should be on a page showing 'Are you sure you want to remove Pugsley Addams from the application'
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    And I should not see 'Pugsley Addams'
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see 'Wednesday Adams'
    When I click Check Your Answers Change link for dependant '1'
    Then I should be on a page showing 'Amend dependant details'
    When I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"
    When I click 'Continue'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's bank accounts"
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
    Then I select "None of these savings or investments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    Then I select "None of these assets"
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or trusts'
    When I select 'England Infected Blood Support Scheme'
    And I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
