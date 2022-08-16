Feature: mini-loop
  @javascript @vcr
  Scenario: When the application has multiple proceedings and I'm using delegated functions
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application with multiple proceedings and reached the check your answers page
    When I click Check Your Answers Change link for 'child_arrangements_order_contact_used_delegated_functions_on'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 55 days ago
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\n!\nThe date you said you used delegated functions is over one month old.'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: When the application has multiple proceedings and I'm using delegated functions
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application with multiple proceedings and reached the check your answers page
    When I click Check Your Answers Change link for 'inherent_jurisdiction_high_court_injunction_used_delegated_functions_on'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And I should not see a govuk formatted date from "10" days ago
    When I click Check Your Answers Change link for 'inherent_jurisdiction_high_court_injunction_used_delegated_functions_on'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 55 days ago
    When I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\n!\nThe date you said you used delegated functions is over one month old.'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 5 days ago
    And I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
