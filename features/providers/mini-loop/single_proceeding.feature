Feature: Mini-loop
  @javascript
  Scenario: When the application has a single proceeding and I'm not using delegated functions
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application and reached the proceedings list
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'

  @javascript
  Scenario: When the application has a single proceeding and I'm going to use delegated functions
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application and reached the proceedings list
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 5 days ago
    When I click 'Save and continue'
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'
