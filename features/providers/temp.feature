Feature: Checking ccms means does NOT auto grant
  @javascript @vcr
  Scenario: I am able to create a passported application with Cap Contribs > £3k and with restrictions
    Given the setting to manually review all cases is enabled
    And I have a passported application with no assets on the "savings_and_investments" page
    Then I visit the applications page
    Then I view the previously created application
    Then I click 'Save and continue'
    Then I am on the "Which types of savings or investments does your client have?" page
    And I check 'Money not in a bank account'
    Then I fill "savings-amount-cash-field" with "4000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Are there any legal restrictions that prevent your client from selling or borrowing against their assets?"
    Then I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Select if your client has received payments from these schemes or charities"
    Then I check "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And I should be on a page showing 'Money not in a bank account'
    And I should be on a page showing '£4,000'
    Then I click 'Save and continue'
    And I should be on a page showing "may need to pay towards legal aid"
    And I should be on a page showing "We’ve calculated that your client should pay £1,000 from their disposable capital."