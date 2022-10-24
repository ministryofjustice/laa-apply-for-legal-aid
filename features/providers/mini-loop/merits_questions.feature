Feature: mini-loop additional merits questions
  @javascript @vcr
  Scenario: Clicking the merits questions out of sequence allow a group to be completed regardless of start point
    # When the application has a domestic abuse proceeding where the client is not an applicant
    # additional questions are included in the grouping
    Given the feature flag for enable_mini_loop is enabled
    And I have started an application where the client is a defendant on the domestic abuse proceeding
    When I visit the merits question page
    Then I should see "Latest incident details"
    And I should see "Opponent details"
    And I should see "Statement of case"
    And I should see "Client denial of allegation"
    And I should see "Children involved in this application"
    When I click link "Statement of case"
    Then I should be on a page showing "Provide a statement of case"
    When I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'
    Then I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    When I enter the 'told' date of 2 days ago
    And I enter the 'occurred' date of 2 days ago
    When I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    When I fill "Full Name" with "John Doe"
    And I choose option "Application merits task opponent understands terms of court order True field"
    And I choose option "Application merits task opponent warning letter sent True field"
    And I choose option "Application merits task opponent police notified True field"
    And I choose option "Application merits task opponent bail conditions set True field"
    And I fill "Bail conditions set details" with "Foo bar"
    And I fill "Police notified details" with "Foo bar"
    When I click 'Save and continue'
    Then I should be on a page showing "Does the client wholly or substantially deny any allegations?"
    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "Has the client offered undertakings?"
    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old
    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"
    And I should see "Latest incident details\nCOMPLETED"
    And I should see "Opponent details\nCOMPLETED"
    And I should see "Statement of case\nCOMPLETED"
    And I should see "Client denial of allegation\nCOMPLETED"
    And I should see "Client offer of undertaking\nCOMPLETED"
    And I should see "Children involved in this application\nCOMPLETED"
