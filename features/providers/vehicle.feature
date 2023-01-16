Feature: vehicle
  @javascript
  Scenario: Complete the vehicle part of the journey
    Given I start the journey as far as the start of the vehicle section
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
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
