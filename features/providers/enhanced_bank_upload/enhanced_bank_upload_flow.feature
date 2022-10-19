Feature: Enhanced bank upload flow
  @javascript
  Scenario: Enhanced bank statement upload journey
    Given csrf is enabled
    And the feature flag for enhanced_bank_upload is enabled
    And I have completed a non-passported employed application with enhanced bank upload as far as the open banking consent page
    Then I should be on a page showing "Does your client use online banking?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Upload bank statements"
    And the page is accessible

    Given I upload the fixture file named "acceptable.pdf"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "acceptable.pdf UPLOADED"
    And I should see "hello_world.pdf UPLOADED"

    When I click "Save and continue"
    Then I should be on a page with title matching "Review .*'s employment income"
    And I should be on a page showing "Do you need to tell us anything else about your client's employment?"
    And the page is accessible

    When I click "Save and continue"
    Then I should be on the "regular_incomes" page showing "Which of the following payments does your client receive?"
    And I should see govuk-details 'Disregarded benefits'
    And the page is accessible

    When I open the section 'Disregarded benefits'
    Then the following sections should exist:
      | tag | section |
      | h2  | Carer and disability benefits |
      | h2  | Low income benefits |
      | h2  | Other benefits |

    When I check "Benefits"
    Then I should not see "Monthly"
    And I fill "Benefits amount" with "500"
    And I choose "providers-means-regular-income-form-benefits-frequency-weekly-field"

    Then I check "Pension"
    Then I should see "Monthly"
    And I fill "Pension amount" with "100"
    And I choose "providers-means-regular-income-form-pension-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client receives in cash"
    And I should see "Benefits"
    And I should see "Pension"
    And the page is accessible

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client receive student finance?"
    And the page is accessible

    When I choose "Yes"
    And I enter amount "2000"
    And I click "Save and continue"
    Then I should be on the "regular_outgoings" page showing "Which of the following payments does your client make?"
    And the page is accessible

    When I select "Housing payments"
    And I fill "Rent or mortgage amount" with "500"
    And I choose "providers-means-regular-outgoings-form-rent-or-mortgage-frequency-three-monthly-field"

    Then I select "Childcare"
    And I fill "Child care amount" with "100"
    And I choose "providers-means-regular-outgoings-form-child-care-frequency-four-weekly-field"

    When I click "Save and continue"
    Then I should be on the "housing_benefits" page showing "Does your client receive housing benefit?"
    And the page is accessible

    When I choose "Yes"
    And I enter amount "100"
    And I choose "Every week"
    And I click "Save and continue"
    Then I should be on a page with title "Select payments your client makes in cash"
    And the page is accessible

    Then I should be on a page with title "Select payments your client makes in cash"
    And I should see "Housing"
    And I should see "Childcare"
    And I should not see "Maintenance payments to a former partner"
    And I should not see "Payments towards legal aid in a criminal case"
    And the page is accessible

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have any dependants?"
