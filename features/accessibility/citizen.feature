Feature: Citizen accessibility

  @javascript @vcr
  Scenario: I start the financial assessment and it is accessible
    Given An application has been created
    And a "true layer bank" exists in the database
    Then I visit the start of the financial assessment
    Then I click link "Privacy policy"
    Then I should be on a page showing "Types of personal data we process"
    And the page is accessible
    Then I click link "Back"
    Then I should be on a page showing 'Your legal aid application'
    And the page is accessible
    When I click link 'Start'
    Then I should be on a page showing 'Do you agree to share 3 months of bank statements with the LAA via TrueLayer?'
    And the page is accessible
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Select your bank'
    And the page is accessible
    Then I click link "Back"
    Then I should be on a page showing 'Do you agree to share 3 months of bank statements with the LAA via TrueLayer?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Contact your solicitor to continue your application'
    And the page is accessible
    Then I click link "Back"
    Then I should be on a page showing 'Do you agree to share 3 months of bank statements with the LAA via TrueLayer?'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I choose 'HSBC'
    Then I click 'Save and continue'
    Then I am directed to TrueLayer

  @javascript
  Scenario: I complete the financial assessment and it is accessible
    Given An application has been created
    Then I visit the start of the financial assessment
    Then I visit the accounts page
    And the page is accessible
    Then I click link 'Continue'
    Then I should be on a page showing "Do you have accounts with other banks?"
    And the page is accessible
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the page is accessible
    Then I click "Agree and submit"
    Then I should be on a page showing "You've shared your financial information"
    And the page is accessible
    Then I click link "feedback"
    Then I should be on a page showing "How easy or difficult was it to use this service?"
    And the page is accessible
