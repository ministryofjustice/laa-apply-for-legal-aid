# I think this can be deleted, we test the categorisation done by the provider elsewhere, this tests after client has added categories, a feature that will be removed
#Feature: Completing and checking means answers backwards and forwards
#
#  @javascript @vcr
#  Scenario: I add a benefits category and add transactions to included and excluded benefits
#    Given The means questions have been answered by the applicant
#    And Bank transactions exist
#    Then I should be on a page showing 'Your client has shared their financial information'
#    Then I click 'Continue'
#    Then I should be on a page showing "Your client's income"
#    Then I choose "No"
#    Then I click 'Save and continue'
#    And I should be on a page showing 'Which payments does your client receive?'
#    And I should see 'Benefits'
#    And I should see 'Financial help from friends or family'
#    And I should see 'Maintenance payments'
#    And I should see 'Pension'
#    And I should not see 'Disregarded benefits'
#    Then I select 'Benefits'
#    And I select 'Financial help from friends or family'
#    And I click 'Save and continue'
#    And I should be on a page showing "Sort your client's income into categories"
#    And I should see 'Benefits'
#    And I should see 'Disregarded benefits'
#    And I should see 'Financial help from friends or family'
#    Then I click on the View statements and add transactions link for 'Excluded benefits'
#    And I should be on a page showing 'Select disregarded benefits payments'
