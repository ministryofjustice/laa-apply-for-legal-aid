Feature: proceeding-loop

  @javascript @vcr
  Scenario: When the application has multiple proceedings with delegated functions and I use the back button
    Given I have started an application with multiple proceedings
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
    Then I should be on the 'has_other_proceedings' page showing "Do you want to add another proceeding?"
    When I choose 'No'
    When I click 'Save and continue' 5 times
    Then I should be on the 'limitations' page showing 'Inherent jurisdiction high court injunction'
