Feature: Choosing full representation level of service in proceeding loop

  @javascript @vcr
  Scenario: When the provider changes the level of service to full representation from the default
    Given the feature flag for enable_loop is enabled
    And I have started an application and reached the proceedings list
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What does your client want legal aid for?"
    When I search for proceeding 'Child arrangements order'
    And proceeding suggestions has results
    When I choose a proceeding type 'Child arrangements order (contact)' radio button
    When I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nSubstantive application'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\nSubstantive application'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\nFor the substantive application, select the level of service'
    When I choose 'Full Representation'
    And I click 'Save and continue'
    Then I should see 'Has the proceeding been listed for a final contested hearing?'
    When I choose 'No'
    And I fill "final-hearing-details-field" with "Valid reasons for not listing the proceeding"
    And I click 'Save and continue'
    Then I should see 'For the substantive application, select the scope'
    When I select 'Blood Tests or DNA Tests'
    And I click 'Save and continue'
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'
