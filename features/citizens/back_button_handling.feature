Feature: Citizen journey bac
  @javascript
  Scenario: Start citizen journey and check back button
    Given An application has been created
    And a "true layer bank" exists in the database
    Then I visit the start of the financial assessment
    Then I should be on a page showing 'Share your financial information with us'
    Then I click link 'Start'
    Then I should be on a page showing 'Give one-time access to your bank accounts'
    And I should see a link ending with '/citizens/legal_aid_applications?back=true'
    Then I click link 'Back'
    Then I should be on a page showing 'Share your financial information with us'
