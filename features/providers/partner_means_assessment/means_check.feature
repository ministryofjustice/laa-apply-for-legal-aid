Feature: partner_means_assessment means check
  @javascript
  Scenario: I am able to navigate to partners means check when doing manual bank upload
    Given csrf is enabled
    And I complete the journey as far as regular outgoings

    When I select "My client makes none of these payments"
    And I click "Save and continue"
    Then I should be on a page with title "Complete the partner's financial assessment"

    When I click "Save and continue"
    Then I should be on a page with title "What is the partner's employment status?"

    When I select "Employed"
    And I click "Save and continue"
    Then I should be on a page with title "Upload the partner's bank statements"

    Given I upload the fixture file named "acceptable.pdf"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "acceptable.pdf Uploaded"
    And I should see "hello_world.pdf Uploaded"

  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to navigate to partners means check when doing open banking upload
    Given the feature flag for collect_hmrc_data is enabled
    And I am logged in as a provider
    And csrf is enabled
    And an applicant named Ida Paisley with a partner has completed their true layer interactions

    When I visit the in progress applications page
    And I click link 'Ida Paisley'
    Then I should be on a page showing "Continue Ida Paisley's financial assessment"

    When I click 'Continue'
    Then I should be on a page showing "HMRC found a record of your client's employment"

    When I fill "legal-aid-application-full-employment-details-field" with "Paisley also earns 50 gbp"
    And I click 'Save and continue'
    Then I should be on a page showing "Which of these payments does your client get?"

    When I select 'Pension'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"

    When I select "My client receives none of these payments in cash"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client get student finance?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Which of these payments does your client pay?"

    When I select 'Housing payments'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client pays in cash"

    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select pension payments'

    When I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"

    When I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select housing payments'

    When I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on a page with title "Complete the partner's financial assessment"
