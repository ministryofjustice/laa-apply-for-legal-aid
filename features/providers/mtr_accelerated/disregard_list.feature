Feature: Disregarded benefits list changes for MTR-Accelerated measures
# TODO: AP-5493 - This whole file can probably be deleted after the MTR-A feature flag is removed

  @javascript
  Scenario: When the MTR-A feature flag is off I should see the legacy disregard list
    Given the feature flag for means_test_review_a is disabled
    And I have completed a non-passported non-employed application for "applicant" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'state_benefits'
    Then I should see govuk-details 'What not to include'

    When I open the section 'What not to include'
    Then the following sections should exist:
      | tag | section |
      | h2  | Government Cost of Living Payments |
      | h2  | Disregarded benefits |
      | h3  | Carer and disability benefits |
      | h3  | Low income benefits |
      | h3  | Other benefits |

    Then I should see 'They are known as mandatory disregards'
    And I should see 'Benefit Transfer Advance \(Universal Credit\)'
    And I should see 'Council Tax Reduction'
    And I should see 'Earnings Top-up \(ETU\)'
    And I should see 'Widow's Pension lump sum payments'

    And I should not see 'Universal Credit advance payments'
    And I should not see 'Compensation for miscarriage of justice'
    And I should not see 'Infected Blood Support Scheme'
    And I should not see 'Modern Slavery'
    And I should not see 'Scotland and Northern Ireland Redress Schemes'

  @javascript
  Scenario: When the MTR-A feature flag is on I should see the MTR-A disregard list
    Given the feature flag for means_test_review_a is enabled
    And the MTR-A start date is in the past
    And I have completed a non-passported non-employed application for "applicant" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click Check Your Answers Change link for applicant 'state_benefits'
    Then I should see govuk-details 'What not to include'

    When I open the section 'What not to include'
    Then the following sections should exist:
      | tag | section |
      | h2  | Government Cost of Living Payments |
      | h2  | Disregarded benefits and payments |
      | h3  | Carer and disability |
      | h3  | Low income |
      | h3  | Other |

    Then I should see 'They are known as mandatory disregards'
    And I should not see 'Benefit Transfer Advance'
    And I should not see 'Council Tax Reduction'
    And I should not see 'Earnings Top-up'
    And I should not see 'Widow's Pension'

    And I should see 'Universal Credit advance payments'
    And I should see 'Compensation for miscarriage of justice'
    And I should see 'Infected Blood Support Scheme\nIncludes Infected Blood Interim Compensation Payment Scheme, Infected Blood Further Interim Compensation Scheme, Infected Blood Compensation Scheme, arrangements made under section 56\(1\) of the Victims and Prisoners Act 2024 or earlier support schemes'
    And I should see 'Modern Slavery Victim Care Contract \(MSVCC\) payments'
    And I should see 'Scotland and Northern Ireland Redress Schemes for historical child abuse payment'
