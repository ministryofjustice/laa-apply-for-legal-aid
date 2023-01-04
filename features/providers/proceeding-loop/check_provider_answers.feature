Feature: proceeding-loop check provider answers

  @javascript @vcr
  Scenario: When I want to change something for an application that has multiple proceedings
    Given the feature flag for enable_loop is enabled
    And I have started an application with multiple proceedings and reached the check your answers page
    Then I should be on a page with title matching 'Check your answers'
    And I should see 'Higher cost limit requested No'
    When I click Check Your Answers Change link for proceeding 'inherent_jurisdiction_high_court_injunction'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nSubstantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'
    And I should not see 'Higher cost limit requested'
    When I click 'Save and continue'
    Then I should be on a page with title matching 'Check your answers'
