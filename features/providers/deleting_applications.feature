Feature: Deleting applications

  @javascript
  Scenario: I can delete a previously created application which has not yet been submitted via the modal when JavaScript is enabled
    Given I have created but not submitted an application
    When I visit the applications page
    And I click delete for the previously created application
    Then I should be on the '/applications' page showing 'Are you sure you want to delete this application?'
    When I click 'Yes, delete it'
    Then I should be on a page showing 'Your applications'
    And I should not see the previously created application

  @javascript
  Scenario: I cannot delete a previously created application which has been submitted
    Given I have created and submitted an application
    When I visit the applications page
    Then I should not see 'Delete'
