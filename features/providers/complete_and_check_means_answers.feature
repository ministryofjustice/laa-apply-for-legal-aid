Feature: Completing and checking means answers backwards and forwards

  @javascript
  Scenario: I select some outgoing transaction types and then remove them
    Given The means questions have been answered by the applicant
    Then I should be on a page showing 'Your client has shared their financial information'
    Then I click 'Continue'
    Then I should be on the 'identify_types_of_income' page showing "Which of these payments does your client get?"

    Then I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client gets in cash"

    When I select "My client gets none of these payments in cash"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client get student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"

    Then I select "Childcare"
    And I click 'Save and continue'
    Then I should be on the 'cash_outgoing' page showing "Select payments your client pays in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'
    When I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select childcare payments'
    When I select the first checkbox
    And I click 'Save and continue'
    Then I click 'Save and continue'
    When I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'

  @javascript @vcr
  Scenario: I navigate to the Check your answers page and then add some outgoing transaction types
    Given The means questions have been answered by the applicant
    Then I should be on a page showing 'Your client has shared their financial information'

    When I click 'Continue'
    Then I should be on the 'identify_types_of_income' page showing "Which of these payments does your client get?"

    When I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client gets in cash"

    When I select "My client gets none of these payments in cash"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client get student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"

    When I select "Childcare"
    And I click 'Save and continue'
    Then I should be on the 'cash_outgoing' page showing "Select payments your client pays in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page with title "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'

    When I select the first checkbox
    And I click 'Save and continue'
    Then I should be on a page with title "Sort your client's income into categories"

    When I click 'Save and continue'
    Then I should be on a page with title "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select childcare payments'

    When I select the first checkbox
    And I click 'Save and continue'
    Then I should be on a page with title "Sort your client's regular payments into categories"

    When I click 'Save and continue'
    Then I should be on a page with title "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

    When I click Check Your Answers Change link for "Payments your client pays"
    Then I should be on a page with title "Which of these payments does your client pay?"

    When I click 'Save and continue'
    Then I should be on a page with title "Select payments your client pays in cash"

    When I click 'Save and continue'
    Then I should be on a page showing "Sort your client's regular payments into categories"

    When I click link 'Add another type of regular payment'
    Then I should be on a page showing 'Which of these payments does your client pay?'

    When I click 'Save and continue'
    Then I should be on a page showing "Select payments your client pays in cash"
    And I click 'Save and continue'
    Then I should be on a page showing "Sort your client's regular payments into categories"

    When I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"

    When I click 'Continue'
    Then I should be on a page showing "Does your client own the home they usually live in?"

    When I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Your client's bank accounts"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"

    When I select "None of these savings or investments"
    And I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"

    When I select "None of these assets"
    And I click 'Save and continue'
    Then I should be on a page showing "Disregarded payments"

    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on a page showing "Payments to be reviewed"

    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'


  @javascript
  Scenario: I change the applicant answer about having any dependants to Yes and add dependants
    Given I am checking the applicant's means income answers
    Then the answer for 'dependants' should be 'No'
    Then I click Check Your Answers Change link for 'dependants'
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
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see 'Dependant 1'
    And I should see 'Dependant 2'
    And the answer for 'dependants' should be 'Yes'

  @javascript
  Scenario: I change the applicant answer about having any dependants to No
    Given I am checking the applicant's means income answers
    Then the answer for 'dependants' should be 'No'
    Then I click Check Your Answers Change link for 'dependants'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants/new' page showing "Enter dependant details"
    When I add the details for a child dependant
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see 'Dependant 1'
    And the answer for 'dependants' should be 'Yes'
    When I click Check Your Answers Change link for 'dependants'
    Then I should be on the 'has_other_dependants' page showing "Does your client have any other dependants?"
    When I click link "Remove"
    Then I should be on a page showing "Are you sure you want to remove Wednesday Adams from the application?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the "has_dependants" page showing "Does your client have any dependants?"
    When I choose "No"
    And I click "Save and continue"
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should not see 'Dependant 1'
    And the answer for 'dependants' should be 'No'

  @javascript
  Scenario: I change the applicant answer about owning a vehicle
    Given I am checking answers on the check capital answers page
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I should be on a page with title 'Does your client have any other vehicles?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page with title 'Check your answers'

  @javascript
  Scenario: I change the applicant answers about details of their vehicle
    Given I am checking answers on the check capital answers page
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I choose 'Yes'
    Then I click 'Save and continue'
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
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I change the applicant answers about offline savings accounts
    Given I am checking answers on the check capital answers page
    Then I should be on a page showing 'Has savings accounts they cannot access online'
    And I should be on a page showing 'Amount in offline savings accounts'
    And the answer for 'has offline savings' should be 'Yes'
    Then I click Check Your Answers Change link for 'offline savings accounts'
    Then I should be on the 'applicant_bank_account' page showing 'Does your client have any savings accounts they cannot access online?'
    And I should be on a page showing 'Enter the total amount in all accounts.'
    Then I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
    And the answer for 'has offline savings' should be 'No'
    And I should not see 'Amount in offline savings accounts'

  @javascript
  Scenario: I go back and change the answer to second home from the check capital answers page
    Given I am checking answers on the check capital answers page
    Then I should be on a page showing 'Which assets does your client have?'
    And I should be on a page showing 'Second property or holiday home estimated value'
    Then I click Check Your Answers Change link for 'other assets'
    And I should be on a page showing 'Which assets does your client have?'
    And I should be on a page showing 'Select all that apply'
    Then I deselect 'Second property or holiday home'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
    And the answer for 'Second home' should be 'No'
    And I should not see 'Second property or holiday home estimated value'

