Feature: Deleting applications

  @javascript
  Scenario: I can delete a previously created application
    Given I have previously created multiple applications
    When I visit the applications page
    And I click delete for the previously created application
    Then I should be on the '/delete' page showing 'Are you sure you want to delete this application?'
    When I click 'Yes, delete it'
    Then I should be on a page showing 'Your applications'
    And I should not see the previously created application
