Feature: Bank statement upload journey happy path
  @javascript
  Scenario: I can upload bank statements and answer transaction questions for non-passported, non-TrueLayer applications on behalf of employed clients
    Given csrf is enabled
    And I have completed a non-passported employed application with bank statements as far as the open banking consent page
    Then I should be on a page showing "Does your client use online banking?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Upload your client's bank statements"

    Given I upload the fixture file named "acceptable.pdf"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "acceptable.pdf Uploaded"
    And I should see "hello_world.pdf Uploaded"

    When I click "Save and continue"
    Then I should be on a page with title matching "Review .*'s employment income"
    And I should be on a page showing "Do you need to tell us anything else about your client's employment?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title matching "Does your client get any benefits, charitable or government payments?"
    And I choose "No"

    When I click "Save and continue"
    Then I should be on the "regular_incomes" page showing "Which of these payments does your client get?"
    And I should see govuk-details 'What not to include'

    When I open the section 'What not to include'
    Then the following sections should exist:
      | tag | section |
      | h2  | Government Cost of Living Payments |
      | h2  | Disregarded benefits |
      | h3  | Carer and disability benefits |
      | h3  | Low income benefits |
      | h3  | Other benefits |

    Then I check "Pension"
    Then I should see "Monthly"
    And I fill "Pension amount" with "100"
    And I choose "providers-means-regular-income-form-pension-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client receives in cash"
    And I should see "Pension"

    When I select "My client receives none of these payments in cash"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client get student finance?"

    When I choose "Yes"
    And I enter amount "2000"
    And I click "Save and continue"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does your client pay?"

    When I select "Housing payments"
    And I fill "Rent or mortgage amount" with "500"
    And I choose "providers-means-regular-outgoings-form-rent-or-mortgage-frequency-three-monthly-field"

    Then I select "Childcare"
    And I fill "Child care amount" with "100"
    And I choose "providers-means-regular-outgoings-form-child-care-frequency-four-weekly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client pays in cash"
    And I should see "Housing"
    And I should see "Childcare"
    And I should not see "Maintenance payments to a former partner"
    And I should not see "Payments towards legal aid in a criminal case"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on the "housing_benefits" page showing "Does your client get Housing Benefit?"

    When I choose "Yes"
    And I enter amount "100"
    And I choose "Every week"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have any dependants?"

  @javascript
  Scenario: I can upload bank statements and answer transaction questions for non-passported, non-TrueLayer applications on behalf of unemployed clients
    Given csrf is enabled
    And I have completed a non-passported unemployed application with bank statements as far as the open banking consent page
    Then I should be on a page showing "Does your client use online banking?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Upload your client's bank statements"

    Given I upload the fixture file named "acceptable.pdf"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "acceptable.pdf Uploaded"
    And I should see "hello_world.pdf Uploaded"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does your client get any benefits, charitable or government payments?"
    And I choose "No"

    When I click "Save and continue"
    Then I should be on the "regular_incomes" page showing "Which of these payments does your client get?"
    And I should see govuk-details 'What not to include'

    When I open the section 'What not to include'
    Then the following sections should exist:
      | tag | section |
      | h2  | Government Cost of Living Payments |
      | h2  | Disregarded benefits |
      | h3  | Carer and disability benefits |
      | h3  | Low income benefits |
      | h3  | Other benefits |

    Then I check "Pension"
    Then I should see "Monthly"
    And I fill "Pension amount" with "100"
    And I choose "providers-means-regular-income-form-pension-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client receives in cash"
    And I should see "Pension"

    When I select "My client receives none of these payments in cash"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client get student finance?"

    When I choose "Yes"
    And I enter amount "2000"
    And I click "Save and continue"
    Then I should be on the "regular_outgoings" page showing "Which of these payments does your client pay?"

    When I select "Housing payments"
    And I fill "Rent or mortgage amount" with "500"
    And I choose "providers-means-regular-outgoings-form-rent-or-mortgage-frequency-three-monthly-field"

    Then I select "Childcare"
    And I fill "Child care amount" with "100"
    And I choose "providers-means-regular-outgoings-form-child-care-frequency-four-weekly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client pays in cash"
    And I should see "Housing"
    And I should see "Childcare"
    And I should not see "Maintenance payments to a former partner"
    And I should not see "Payments towards legal aid in a criminal case"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on the "housing_benefits" page showing "Does your client get Housing Benefit?"

    When I choose "Yes"
    And I enter amount "100"
    And I choose "Every week"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have any dependants?"
