Feature: Completing and checking means answers backwards and forwards

  @javascript
  Scenario: I add a benefits category and add transactions to included and excluded benefits
    Given The means questions have been answered by the applicant
    And Bank transactions exist
    Then I should be on a page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on a page showing "Sort your client's income into categories"
    Then I click link 'Add another type of income'
    And I should be on a page showing 'Which types of income does your client receive?'
    And I should see 'Benefits'
    And I should see 'Financial help from friends or family'
    And I should see 'Maintenance payments'
    And I should see 'Student loan or grant'
    And I should see 'Pension'
    And I should not see 'Disregarded benefits'
    Then I select 'Benefits'
    And I select 'Student loan or grant'
    And I click 'Save and continue'
    And I should be on a page showing "Sort your client's income into categories"
    And I should see 'Benefits'
    And I should see 'Excluded benefits'
    And I should see 'Student loan or grant'

    Then I click on the View statements and add transactions link for 'Excluded benefits'
    And I should be on a page showing 'Excluded Benefits'

    Then show me the page



