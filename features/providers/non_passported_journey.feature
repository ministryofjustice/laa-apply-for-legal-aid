Feature: Non-passported applicant journeys
  @javascript
  Scenario: Completes a minimal merits application for applicant that does not receive benefits
    Given I start the merits application
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And I should see 'Add dependant'

  @javascript @vcr
  Scenario: Selects and categorises bank transactions into transaction types
    Given I start the merits application with brank transactions with no transaction type category
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    When I click link 'Add another type of income'
    And I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    Then I click the first link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    When I click link 'Add another type of regular payment'
    And I select 'Childcare costs'
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click link 'View statements and add transactions'
    Then I select the first checkbox
    And I click 'Save and continue'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Does your client own the home that they live in?'


  @javascript
  Scenario: Complete a merits application for applicant that does not receive benefits with dependants
    Given I start the merits application
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants' page showing "Enter the first dependant's details for your client"
    When I fill "Name" with "Wednesday Adams"
    And I enter a date of birth for a 17 year old
    And I click "Save and continue"
    Then I should be on a page showing "What is your clients' relationship to"
    When I choose "They're a child relative"
    And I click "Save and continue"
    Then I should be on a page showing "receive any income?"
    When I choose "Yes"
    And I fill "monthly income" with "1234"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependant' page showing "Does your client have any other dependants?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'dependants' page showing "Enter the second dependant's details for your client"
    When I fill "Name" with "Pugsley Adams"
    And I enter a date of birth for a 21 year old
    And I click "Save and continue"
    Then I should be on a page showing "What is your clients' relationship to"
    When I choose "They're a child relative"
    And I click "Save and continue"
    Then I should be on the 'full_time_education' page showing "in full-time education or training?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "receive any income?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependant' page showing "Does your client have any other dependants?"
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on the 'dependants' page showing "Enter the third dependant's details for your client"
    When I fill "Name" with "Granny Addams"
    And I enter a date of birth for a 80 year old
    And I click "Save and continue"
    Then I should be on the 'relationship' page showing "What is your clients' relationship to"
    When I choose "They're an adult relative"
    And I click "Save and continue"
    Then I should be on the 'monthly_income' page showing "receive any income?"
    When I choose "Yes"
    And I fill "monthly income" with "4321"
    And I click 'Save and continue'
    Then I should be on the 'assets_value' page showing "have assets worth more than £8,000?"
    When I choose "Yes"
    And I fill "assets value" with "8765"
    And I click 'Save and continue'
    Then I should be on the 'has_other_dependant' page showing "Does your client have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

  @javascript
  Scenario: Complete a merits application for applicant that does not receive benefits with a child dependant
    Given I start the merits application
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants' page showing "Enter the first dependant's details for your client"
    When I fill "Name" with "Wednesday Adams"
    And I enter a date of birth for a 14 year old
    And I click "Save and continue"
    Then I should be on the 'has_other_dependant' page showing "Does your client have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And I should see 'Wednesday Adams'

  @javascript
  Scenario: Complete a merits application for applicant that does not receive benefits with no dependants but other values
    Given I start the merits application
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
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
    Then I choose option "Vehicle payments remain true"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "Did your client buy the vehicle over 3 years ago?"
    Then I choose 'Yes'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    Then I choose option "Vehicle used regularly true"
    And I click "Save and continue"
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Are there any legal restrictions that prevent your client from selling or borrowing against their assets?"
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
