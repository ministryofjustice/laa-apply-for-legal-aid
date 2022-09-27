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
    And I click "Save and continue"
    Then I should be on a page with title matching "Review .*'s employment income"
    And I should be on a page showing "Do you need to tell us anything else about your client's employment?"
    And the page is accessible

    When I click "Save and continue"
    Then I should be on the "regular_incomes" page showing "Which of the following payments does your client receive?"
    And the page is accessible

    When I check "Benefits"
    And I fill "Benefits amount" with "500"
    And I choose "providers-means-regular-income-form-benefits-frequency-weekly-field"

    Then I check "Pension"
    And I fill "Pension amount" with "100"
    And I choose "providers-means-regular-income-form-pension-frequency-monthly-field"

    When I click "Save and continue"
    Then I should be on a page with title "Select payments your client receives in cash"
    And the page is accessible

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client receive student finance?"
    And the page is accessible

    When I choose "Yes"
    And I enter amount "2000"
    And I click "Save and continue"
    Then I should be on a page with title "Which payments does your client make?"
    And the page is accessible
