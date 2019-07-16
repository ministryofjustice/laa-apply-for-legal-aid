Feature: Citizen journey through dependants pages

  @javascript
  Scenario: I have a dependant under 15
    Given An application has been created
    Then I visit the first question about dependants
    Then I should be on a page showing "Do you have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your first dependant's details"
    Then I fill "Name" with "Pugsley Addams"
    Then I enter a date of birth for a 10 year old
    Then I click "Save and continue"
    Then I should be on a page showing "Do you have any other dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should have completed the dependants section of the journey

  @javascript
  Scenario: I have a 16-18 year old child dependant
    Given An application has been created
    Then I visit the first question about dependants
    Then I should be on a page showing "Do you have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your first dependant's details"
    Then I fill "Name" with "Pugsley Addams"
    Then I enter a date of birth for a 17 year old
    Then I click "Save and continue"
    Then I should be on a page showing "What is your relationship to"
    Then I choose "They're a child relative"
    Then I click "Save and continue"
    Then I should be on a page showing "receive any income?"
    Then I choose "Yes"
    Then I fill "monthly income" with "1234"
    Then I click 'Save and continue'
    Then I should be on a page showing "Do you have any other dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should have completed the dependants section of the journey

  @javascript
  Scenario: I have a child dependant over 18 and in fulltime education
    Given An application has been created
    Then I visit the first question about dependants
    Then I should be on a page showing "Do you have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your first dependant's details"
    Then I fill "Name" with "Pugsley Addams"
    Then I enter a date of birth for a 23 year old
    Then I click "Save and continue"
    Then I should be on a page showing "What is your relationship to"
    Then I choose "They're a child relative"
    Then I click "Save and continue"
    Then I should be on a page showing "in full-time education or training?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I choose "Yes"
    Then I fill "monthly income" with "1234"
    Then I click 'Save and continue'
    Then I should be on a page showing "Do you have any other dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should have completed the dependants section of the journey

  @javascript
  Scenario: I have a child dependant over 18 and not in fulltime education
    Given An application has been created
    Then I visit the first question about dependants
    Then I should be on a page showing "Do you have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your first dependant's details"
    Then I fill "Name" with "Pugsley Addams"
    Then I enter a date of birth for a 23 year old
    Then I click "Save and continue"
    Then I should be on a page showing "What is your relationship to"
    Then I choose "They're a child relative"
    Then I click "Save and continue"
    Then I should be on a page showing "in full-time education or training?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "receive any income?"
    Then I choose "Yes"
    Then I fill "monthly income" with "1234"
    Then I click 'Save and continue'
    Then I should be on a page showing "have assets worth more than £8,000?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Do you have any other dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should have completed the dependants section of the journey 

  @javascript
  Scenario: I have an adult dependant more than 15 years old
    Given An application has been created
    Then I visit the first question about dependants
    Then I should be on a page showing "Do you have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your first dependant's details"
    Then I fill "Name" with "Jane Doe"
    Then I enter a date of birth for a 30 year old
    Then I click "Save and continue"
    Then I should be on a page showing "What is your relationship to"
    Then I choose "They're an adult relative"
    Then I click "Save and continue"
    Then I should be on a page showing "receive any income?"
    Then I choose "Yes"
    Then I fill "monthly income" with "1234"
    Then I click 'Save and continue'
    Then I should be on a page showing "have assets worth more than £8,000?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Do you have any other dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should have completed the dependants section of the journey    

  @javascript
  Scenario: I have multiple dependants
    Given An application has been created
    Then I visit the first question about dependants
    Then I should be on a page showing "Do you have any dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your first dependant's details"
    Then I fill "Name" with "Pugsley Addams"
    Then I enter a date of birth for a 10 year old
    Then I click "Save and continue"
    Then I should be on a page showing "Do you have any other dependants?"
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your second dependant's details"
    Then I fill "Name" with "Wednesday Addams"
    Then I enter a date of birth for a 17 year old
    Then I click "Save and continue"
    Then I should be on a page showing "What is your relationship to"
    Then I choose "They're a child relative"
    Then I click "Save and continue"
    Then I should be on a page showing "receive any income?"
    Then I choose "Yes"
    Then I fill "monthly income" with "1234"
    Then I click 'Save and continue'
    Then I should be on a page showing "Do you have any other dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should have completed the dependants section of the journey
