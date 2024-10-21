Feature: Disregarded benefits list changes for MTR-Accelerated measures
# TODO: This whole file can probably be deleted after the MTR-A feature flag is removed

  @javascript
  Scenario: When the MTR-A feature flag is off I should see the legacy disregard list
    Given the feature flag for means_test_review_a is disabled
    And I have completed a non-passported non-employed application for "applicant" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'state_benefits'
    Then I should see govuk-details 'What not to include'

    When I open the section 'What not to include'
    Then I should see 'They are known as mandatory disregards'
    And I should see 'Benefit Transfer Advance \(Universal Credit\)'
    And I should see 'Council Tax Reduction'
    And I should see 'Earnings Top-up \(ETU\)'
    And I should see 'War Widow\(er\) Pension'

    And I should not see 'Universal Credit advance payments'
    And I should not see 'Compensation for miscarriage of justice'
    And I should not see 'Infected Blood Support Scheme \(includes Infected Blood Interim Compensation Payment Scheme, Infected Blood Further Interim Compensation Scheme, Infected Blood Compensation Scheme or earlier support schemes\)'
    And I should not see 'Modern Slavery Viction Care Contract \(MSVCC\) payments'
    And I should not see 'Scotland and Northern Ireland Redress Schemes for historical child abuse payment'

  @javascript
  Scenario: When the MTR-A feature flag is on I should see the MTR-A disregard list
    Given the feature flag for means_test_review_a is enabled
    And I have completed a non-passported non-employed application for "applicant" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'state_benefits'
    Then I should see govuk-details 'What not to include'

    When I open the section 'What not to include'
    Then I should see 'They are known as mandatory disregards'
    And I should not see 'Benefit Transfer Advance \(Universal Credit\)'
    And I should not see 'Council Tax Reduction'
    And I should not see 'Earnings Top-up \(ETU\)'
    And I should not see 'War Widow\(er\) Pension'

    And I should see 'Universal Credit advance payments'
    And I should see 'Compensation for miscarriage of justice'
    And I should see 'Infected Blood Support Scheme \(includes Infected Blood Interim Compensation Payment Scheme, Infected Blood Further Interim Compensation Scheme, Infected Blood Compensation Scheme or earlier support schemes\)'
    And I should see 'Modern Slavery Viction Care Contract \(MSVCC\) payments'
    And I should see 'Scotland and Northern Ireland Redress Schemes for historical child abuse payment'
