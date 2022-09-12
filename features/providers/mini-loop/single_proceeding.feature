Feature: Mini-loop single proceeding
  @javascript @vcr
  Scenario: When the application has a single proceeding and I'm not using delegated functions
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application and reached the proceedings list
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'

  @javascript @vcr
  Scenario: When the application has a single proceeding and I'm going to use delegated functions
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application and reached the proceedings list
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 5 days ago
    When I click 'Save and continue'
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'

  @javascript @vcr
  Scenario: When the application has a single proceeding and I'm going to use an old delegated functions date
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application and reached the proceedings list
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 35 days ago
    When I click 'Save and continue'
    Then I should see 'Proceeding 1\nInherent jurisdiction high court injunction\n!\nThe date you said you used delegated functions is over one month old.'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'
