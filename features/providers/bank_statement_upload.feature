Feature: Bank statement upload

  Background:
    Given csrf is enabled
    And I have completed a non-passported application and reached the open banking consent with bank statement upload enabled
    Then I should be on a page with title "We need your client's bank statements from the last 3 months"
    And I should be on a page showing "Can your client share their bank statements with us via TrueLayer?"
    And I should be on a page showing "You'll need to upload bank statements. Your application may take longer to process as a caseworker will need to check your client's bank statements"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Upload bank statements"
    And the page is accessible

  @javascript
  Scenario: Uploading a file
    When I upload the fixture file named 'empty_file.pdf'
    Then I should see govuk error summary "empty_file.pdf has no content"

    When I upload the fixture file named 'malware.doc'
    Then I should see govuk error summary "malware.doc contains a virus"

    When I upload the fixture file named 'zip.zip'
    Then I should see govuk error summary "zip.zip is not a valid file type"

    When I upload the fixture file named 'too_large.pdf'
    Then I should see govuk error summary "too_large.pdf is larger than 7MB"

    When I click 'Save and continue'
    Then I should be on a page with title "Upload bank statements"
    And I should see govuk error summary "Upload your client's bank statements"

    When I upload the fixture file named 'acceptable.pdf'
    Then I should see 'acceptable.pdf UPLOADED'

    When I click 'Save and continue'
    Then I should be on a page with title "Which payments does your client receive?"

    When I click link "Back"
    Then I should be on a page with title "Upload bank statements"
    And I should see 'acceptable.pdf UPLOADED'

    When I click 'Save and come back later'
    Then I should be on a page with title "Applications"

  @javascript
  Scenario: Deleting a file
      Given I upload the fixture file named 'acceptable.pdf'
      And I upload an evidence file named 'hello_world.pdf'
      And I upload an evidence file named 'hello_world.docx'
      Then I should see 'acceptable.pdf UPLOADED'
      And I should see 'hello_world.pdf UPLOADED'
      And I should see 'hello_world.docx UPLOADED'

      When I click delete for the file 'hello_world.pdf'
      Then I should see 'hello_world.pdf has been successfully deleted'
      And I should see 'acceptable.pdf UPLOADED'
      And I should see 'hello_world.docx UPLOADED'

  @javascript
  Scenario: New bank upload permissions flow
    Given I upload the fixture file named 'acceptable.pdf'
    And I upload an evidence file named 'hello_world.pdf'
    When I click 'Save and continue'
    Then I should be on a page with title "Which payments does your client receive?"
    Then I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page with title "Select payments your client receive in cash"
    Then I select 'None of the above'
#    Then I fill 'aggregated-cash-income-benefits1-field' with '123.00'
#    Then I fill 'aggregated-cash-income-benefits2-field' with '123.00'
#    Then I fill 'aggregated-cash-income-benefits3-field' with '123.00'
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client receive student finance?"
    Then I choose "Yes"
    Then I enter amount '5000'
    When I click 'Save and continue'
    Then I should be on a page with title "Which payments does your client make?"
    Then I check "Housing payments"
    Then I click 'Save and continue'
    Then I should be on a page with title "Select payments your client makes in cash"
    Then I select 'Housing payments'
    Then I select 'None of the above'
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client have any dependants?"
    Then I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
