Feature: non_passported_journey with means
  @javascript @vcr
  Scenario: I am able to complete the means questions and check answers
    Given I start the means application and the applicant has uploaded transaction data
    Then I should be on a page showing 'Your client has shared their financial information'

    When I click 'Continue'
    Then I should be on a page showing "Which of these payments does your client get?"

    When I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"

    When I select "Pension"
    Then I enter pension1 '100'
    Then I enter pension2 '100'
    Then I enter pension3 '100'
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client get student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'identify_types_of_outgoing' page showing "Which of these payments does your client pay?"

    When I select 'Housing'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client pays in cash"

    When I select 'Housing payments'
    Then I enter rent_or_mortgage1 '100'
    Then I enter rent_or_mortgage2 '100'
    Then I enter rent_or_mortgage3 '100'
    And I click 'Save and continue'
    Then I should be on a page showing "Sort your client's income into categories"

    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'
    Then I select the first checkbox
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'
    When I select the first checkbox
    And I click 'Save and continue'
    Then I should be on a page with title "Sort your client's income into categories"

    When I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select housing payments'

    When I select the first checkbox
    And I click 'Save and continue'
    Then I should be on a page with title "Sort your client's regular payments into categories"

    When I click 'Save and continue'
    Then I should be on the 'housing_benefits' page showing "Does your client get Housing Benefit?"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'

    When I click Check Your Answers Change link for "Payments your client receives"
    Then I should be on a page with title "Which of these payments does your client get?"

    When I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"

    When I click 'Save and continue'
    Then I should be on a page showing "Sort your client's income into categories"

    When I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    And I should see "Benefits, charitable or government payments None"

    When I click 'Save and continue'
    Then I should be on a page with title "What you need to do"
    And I should see "Tell us about your client's capital"

    When I click 'Continue'
    Then I should be on a page showing "Does your client own the home they usually live in?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Your client's bank accounts"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"

    When I select "None of these savings or investments"
    And I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"

    When I select "Land"
    And I fill "Land value" with "50000"
    And I click 'Save and continue'
    Then I should be on a page showing "Is your client banned from selling or borrowing against their assets?"

    When I choose 'Yes'
    And I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    And I click 'Save and continue'
    Then I should be on a page showing "Disregarded payments"

    When I check "Infected Blood Support Scheme payment"
    And I click 'Save and continue'
    Then I should be on a page showing "Add details for 'Infected Blood Support Scheme payment'"

    When I fill "amount" with "100"
    And I fill 'account name' with 'Halifax'
    And I enter the 'date received' date of 20 days ago
    And I click "Save and continue"
    Then I should be on a page showing "Payments to be reviewed"

    When I check "My client has not received any of these payments"
    And I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page showing 'We need to check if'
    And I should be on a page showing 'they received disregarded scheme or charity payments'

    When I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Latest incident details Not started'

    When I click link 'Latest incident details'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
