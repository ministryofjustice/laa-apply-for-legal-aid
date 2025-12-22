Feature: Applications page

  @javascript
  Scenario: Test in progress application page
    Given I have created but not submitted an application
    When I visit the in progress applications page
    Then I should see the previously created application
    
    When I visit the submitted applications page
    Then I should be on a page showing "You have 0 applications."

  @javascript
  Scenario: Test submitted application page
    Given I have created and submitted an application
    When I visit the submitted applications page
    Then I should see the previously created application
    
    When I visit the in progress applications page
    Then I should be on a page showing "You have 0 applications."

  @javascript
  Scenario: Test application page for paused submission
    Given I have an application with a paused submission
    When I visit the submitted applications page
    Then I should see the previously created application
    
    When I visit the in progress applications page
    Then I should be on a page showing "You have 0 applications."

  @javascript
    Scenario: Test expired application page
      Given I have created a voided application
      When I visit the in progress applications page
      Then I should be on a page showing "See applications you cannot submit"

      When I click link "See applications you cannot submit"
      Then I should be on a page showing "Applications you cannot submit"
