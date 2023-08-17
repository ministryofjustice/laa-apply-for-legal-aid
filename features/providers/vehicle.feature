Feature: vehicle
  @javascript
  Scenario: Complete the vehicle part of the journey
    Given I start the journey as far as the start of the vehicle section
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
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
