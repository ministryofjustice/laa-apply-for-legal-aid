Feature: Completing and checking means answers backwards and forwards

  @javascript
  Scenario: I select some outgoing transaction types and then remove them
    Given The means questions have been answered by the applicant
    Then I should be on a page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's regular payments"
    Then I click link 'Add another type of regular payment'
    Then I should be on a page showing 'Which regular payments does your client make?'
    Then I select 'Rent or mortgage payments'
    Then I select 'Payments towards legal aid in a criminal case'
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's regular payments"
    Then I should be on a page showing "Rent or mortgage payments"
    Then I should be on a page showing "Payments towards legal aid in a criminal case"
    Then I click link 'Add another type of regular payment'
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's regular payments"
    Then I should be on a page not showing "Rent or mortgage payments"
    Then I should be on a page not showing "Payments towards legal aid in a criminal case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"

  @javascript
  Scenario: I navigate to the Check your answers page and then add some outgoing transaction types
    Given The means questions have been answered by the applicant
    Then I should be on a page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click link 'View/change declared outgoings'
    Then I should be on a page showing "Your client's regular payments"
    Then I click link 'Add another type of regular payment'
    Then I should be on a page showing 'Which regular payments does your client make?'
    Then I select 'Rent or mortgage payments'
    Then I select 'Payments towards legal aid in a criminal case'
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client's regular payments"
    Then I should be on a page showing "Rent or mortgage payments"
    Then I should be on a page showing "Payments towards legal aid in a criminal case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"

  @javascript
  Scenario: I change the applicant answer about owning a vehicle
    Given I am checking the applicant's means answers
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I should be on a page showing 'Does your client own a vehicle?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I change the applicant answers about details of their vehicle
    Given I am checking the applicant's means answers
    Then I click Check Your Answers Change link for 'Vehicles'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the estimated value of the vehicle?"
    Then I fill "Estimated value" with "4000"
    And I click "Save and continue"
    Then I should be on a page showing "Are there any payments left on the vehicle?"
    Then I choose option "Vehicle payments remain true"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "When did your client buy the vehicle?"
    Then I enter the purchase date '21-3-2002'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    Then I choose option "Vehicle used regularly true"
    And I click "Save and continue"
    Then I should be on a page showing 'Check your answers'


