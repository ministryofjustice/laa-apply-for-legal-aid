Feature: Non-passported applicant journeys
  @javascript
  Scenario: Completes a minimal merits application for applicant that does not receive benefits
    Given I start the merits application
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Your client's income"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Your client's regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

  @javascript
  Scenario: Complete a merits application for applicant that does not receive benefits with dependants
    Given I start the merits application
    Then I should be on the 'client_completed_means' page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Your client's income"
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
    Then I should be on a page showing "Do you have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Your client's regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
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
    Then I should be on the 'income_summary' page showing "Your client's income"
    Then I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on the 'dependants' page showing "Enter the first dependant's details for your client"
    When I fill "Name" with "Wednesday Adams"
    And I enter a date of birth for a 14 year old
    And I click "Save and continue"
    Then I should be on a page showing "Do you have any other dependants?"
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Your client's regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
