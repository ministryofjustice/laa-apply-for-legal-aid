Feature: Checking ccms means does NOT auto grant 
  @javascript
  Scenario: I am able to create a passported application with Cap Contribs > £3k and with restrictions
    Given the setting to manually review all cases is enabled
    And I previously created a passported application with no assets and left on the "savings_and_investments" page
    Then I visit the applications page
    Then I view the previously created application
    Then I click 'Save and continue'
    Then I am on the "Which types of savings or investments does your client have?" page
    And I click on "Money not in bank account" checkbox
    Then I fill "Enter the total amount" with "4000"
    Then I click 'Save and continue'
    And show me the page
    Then I should be on a page showing "Which types of assets does your client have?"
