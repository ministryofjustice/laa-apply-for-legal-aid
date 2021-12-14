Feature: Employed journey

@javascript
Scenario: Completing the means journey for an employed applicant with HMRC data
  Given the feature flag for enable_employed_journey is enabled
  Given I start the means review journey with employment income from HMRC
  Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
  When I click 'Continue'
  Then I should be on the 'employment_income' page showing 'The information on this page has been provided by HMRC.'
  When I click 'Save and continue'
  Then I should be on the 'employment_income' page showing "Select yes if you need to tell us anything else about your client's employment"
  When I choose 'Yes'
  And I click 'Save and continue'
  Then I should be on the 'employment_income' page showing "Enter details about your client’s employment"
  When I fill "legal aid application extra employment information details error" with "some extra details about employment"
  And I click 'Save and continue'
  Then I should be on the 'no_income_summary' page showing "Your client's income"

@javascript
Scenario: Completing the means journey for an employed applicant with no HMRC data
  Given the feature flag for enable_employed_journey is enabled
  Given I start the means review journey with no employment income from HMRC
  Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
  When I click 'Continue'
  Then I should be on the 'no_employment_income' page showing "HMRC has no record of your client's employment in the last 3 months"
  When I click 'Save and continue'
  Then I should be on the 'no_employment_income' page showing "Enter your client's employment details"
  Then I fill "legal aid application full employment details error" with "all the details about employment"
  And I click 'Save and continue'
  Then I should be on the 'no_income_summary' page showing "Your client's income"
