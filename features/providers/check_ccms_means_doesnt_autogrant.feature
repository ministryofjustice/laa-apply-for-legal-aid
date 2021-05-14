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
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I click on "None of these" checkbox
    Then I click 'Save and continue'
    Then I should be on a page showing "Are there any legal restrictions that prevent your client from selling or borrowing against their assets?"
    Then I click on the "Yes" radio button
    Then I fill "Tell us which assets they cannot sell or borrow against, and why" with "Mikes cucumber test"
    Then I click 'Save and continue'
    Then I should be on a page showing "Select if your client has received payments from these schemes or charities"
    Then I click on "None of these" checkbox
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click 'Save and continue'
    And show me the page

