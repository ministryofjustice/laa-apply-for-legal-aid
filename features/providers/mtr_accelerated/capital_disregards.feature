Feature: mandatory and discretionary capital disregards questions and flow
# TODO: AP-5493 - This flow file can be moved to a full flow non-passported journey feature after the MTR-A feature flag is removed

  @javascript
  Scenario: When the MTR-A feature flag is off I should not see the mandatory or discretionary capital disregard questions in the flow
    Given the feature flag for means_test_review_a is disabled
    And I have completed a non-passported non-employed application for "applicant" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click "Save and continue"
    Then I should be on a page with title "What you need to do"

    When I click "Continue"
    Then I should be on a page with title "Does your client own the home that they live in?"
    And I choose 'No'

    When I click "Save and continue"
    Then I should be on a page with title "Does your client own a vehicle?"
    And I choose 'No'

    When I click "Save and continue"
    Then I should be on a page with title "Which bank accounts does your client have?"
    And I select "None of these"

    When I click "Save and continue"
    Then I should be on a page with title "Which savings or investments does your client have?"
    And I select "None of these savings or investments"

    When I click "Save and continue"
    Then I should be on a page with title "Which assets does your client have?"
    And I select "None of these assets"

    When I click "Save and continue"
    Then I should be on a page with title "Which schemes or trusts have paid your client?"
    And I select "None of these schemes or trusts"

    When I click "Save and continue"
    Then I should be on the "check_capital_answers" page showing "Check your answers"

  @javascript
  Scenario: When the MTR-A feature flag is on I should see the mandatory and discretionary capital disregard question in the flow
    Given the feature flag for means_test_review_a is enabled
    And the MTR-A start date is in the past
    And I have completed a non-passported non-employed application for "applicant" with bank statements as far as the end of the means income section
    Then I should be on the "check_income_answers" page showing "Check your answers"

    When I click "Save and continue"
    Then I should be on a page with title "What you need to do"

    When I click "Continue"
    Then I should be on a page with title "Does your client own the home they usually live in?"
    And I choose 'No'

    When I click "Save and continue"
    Then I should be on a page with title "Does your client own a vehicle?"
    And I choose 'No'

    When I click "Save and continue"
    Then I should be on a page with title "Which bank accounts does your client have?"
    And I select "None of these"

    When I click "Save and continue"
    Then I should be on a page with title "Which savings or investments does your client have?"
    And I select "None of these savings or investments"

    When I click "Save and continue"
    Then I should be on a page with title "Which assets does your client have?"
    And I select "None of these assets"

    When I click "Save and continue"
    Then I should be on a page with title "Disregarded payments"
    And I should see "Select if your client has received any of these payments"
    And the following sections should exist:
      | tag | section |
      | .govuk-checkboxes__label  | Backdated benefits and child maintenance payments received in the last 24 months |
      | .govuk-checkboxes__label  | Backdated Community Care payments |
      | .govuk-checkboxes__label  | Budgeting Advances |
      | .govuk-checkboxes__label  | Compensation for miscarriage of justice|
      | .govuk-checkboxes__label  | Government cost of living payment |
      | .govuk-checkboxes__label  | Independent Living Fund payment |
      | .govuk-checkboxes__label  | Infected Blood Support Scheme payment |
      | .govuk-checkboxes__label  | Modern Slavery Victim Care Contract (MSVCC) payment |
      | .govuk-checkboxes__label  | Payments on Account of Benefit |
      | .govuk-checkboxes__label  | Scotland and Northern Ireland Redress Schemes for historical child abuse payment |
      | .govuk-checkboxes__label  | Social Fund payment |
      | .govuk-checkboxes__label  | Vaccine Damage Payment |
      | .govuk-checkboxes__label  | Variant Creutzfeldt-Jakob disease (vCJD) Trust payment |
      | .govuk-checkboxes__label  | Welsh Independent Living Grant |
      | .govuk-checkboxes__label  | Windrush Compensation Scheme payment |
  
    And I should see "For example, Pensioner Cost of Living Payment, Cost of Living Payment"
    And I should see "Includes Infected Blood Interim Compensation Payment Scheme"
    And I select "Infected Blood Support Scheme payment"
    And I click "Save and continue"

    When I click link "Back"
    Then I should be on a page with title "Disregarded payments"
    And the checkbox for Government cost of living payment should be unchecked
    And the checkbox for Infected Blood Support Scheme payment should be checked

    When I click "Save and continue"
    Then I should be on a page showing "Add details for 'Infected Blood Support Scheme payment'"
    
    When I click "Save and continue"
    Then I should see govuk error summary "Enter a number for the amount received"
    And I should see govuk error summary "Enter which account the payment is in"
    And I should see govuk error summary "Enter a date in the correct format for when the payment is received"

    When I fill 'amount' with '100'
    And I fill 'account name' with 'Barclays'
    And I enter the 'date received' date of 50 days ago
    And I click "Save and continue"
    Then I should be on a page with title "Payments to be reviewed"
    And I should see "Select if your client has received any of these payments"
    And the following sections should exist:
      | tag | section |
      | .govuk-checkboxes__label  | Backdated benefits and child maintenance payments received more than 24 months ago |
      | .govuk-checkboxes__label  | Compensation, damages or ex-gratia payments for personal harm |
      | .govuk-checkboxes__hint   | For example, payments to victims of abuse |
      | .govuk-checkboxes__label  | Criminal Injuries Compensation Scheme payment |
      | .govuk-checkboxes__label  | Grenfell Tower fire victims payment |
      | .govuk-checkboxes__label  | London Emergencies Trust payment |
      | .govuk-checkboxes__label  | National Emergencies Trust (NET) payment |
      | .govuk-checkboxes__label  | Payments covering loss or harm related to proceedings in this application |
      | .govuk-checkboxes__label  | Victims of Overseas Terrorism Compensation Scheme (VOTCS) 2012 payment |
      | .govuk-checkboxes__label  | We Love Manchester Emergency Fund payment |
    And I select "London Emergencies Trust payment"

    When I click "Save and continue"
    Then I should be on a page showing "Add details for 'London Emergencies Trust payment'"

    When I click link "Back"
    Then I should be on a page with title "Payments to be reviewed"
    And the checkbox for Grenfell Tower fire victims payment should be unchecked
    And the checkbox for London Emergencies Trust payment should be checked

    When I click "Save and continue"
    Then I should be on a page showing "Add details for 'London Emergencies Trust payment'"
    And I fill 'amount' with '200'
    And I fill 'account name' with 'Halifax'
    And I enter the 'date received' date of 20 days ago

    When I click "Save and continue"
    Then I should be on a page showing "Check your answers"
