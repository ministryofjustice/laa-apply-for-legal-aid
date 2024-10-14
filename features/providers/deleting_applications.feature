Feature: Deleting applications

  @javascript
  Scenario: I can delete a previously created application which has not yet been submitted
    Given I have created but not submitted an application
    When I visit the in progress applications page
    And I click delete for the previously created application
    Then I should be on the '/delete' page showing 'Are you sure you want to delete this application?'
    When I click 'Yes, delete it'
    Then I should be on a page showing 'Your applications'
    And I should not see the previously created application
    And I should see 'You deleted the application'

  @javascript
  Scenario: I cannot delete a previously created application which has been submitted
    Given I have created and submitted an application
    When I visit the submitted applications page
    Then I should not see a 'Delete' button
  
  @javascript
  Scenario: I cannot delete a previously created application which has been submitted
    Given I have created a voided application
    When I visit the in progress applications page
    Then I should be on a page showing 'See applications you cannot submit'

  @javascript
  Scenario: Deleting voided applications
    Given I have created a voided application
    When I visit the in progress applications page
    Then I should be on a page showing "See applications you cannot submit"

    When I click link "See applications you cannot submit"
    Then I should be on a page showing "Applications you cannot submit"

    When I click delete for the previously created application
    Then I should be on the '/delete' page showing 'Are you sure you want to delete this application?'
    
    When I click 'Yes, delete it'
    Then I should be on a page with title "Applications you cannot submit"
    And I should be on a page showing "You have 0 applications."
    And I should not see the previously created application

    Then I click link "Back"
    Then I should not see "See applications you cannot submit"
