Feature: proceeding-loop

  @javascript @vcr
  Scenario: When the application has multiple proceedings with delegated functions and I use the back button
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application with multiple proceedings
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on the 'in_scope_of_laspo' page showing "Are the Section 8 proceedings you're applying for in scope of the Legal Aid, Sentencing and Punishment of Offenders Act 2012 (LASPO)?"
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nWhat is your client’s role in this proceeding?'
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1 of 2\nInherent jurisdiction high court injunction\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\nWhat is your client’s role in this proceeding?'
    When I choose 'Defendant/respondent'
    And I click 'Save and continue'
    Then I should see 'Proceeding 2 of 2\nChild arrangements order \(contact\)\nHave you used delegated functions for this proceeding?'
    When I choose 'Yes'
    And I enter the 'delegated functions on' date of 5 days ago
    When I click 'Save and continue'
    When I click the 'back' link 5 times
    Then I should be on the 'in_scope_of_laspo' page showing "Are the Section 8 proceedings you're applying for in scope of the Legal Aid, Sentencing and Punishment of Offenders Act 2012 (LASPO)?"
    When I click 'Save and continue' 5 times
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'
