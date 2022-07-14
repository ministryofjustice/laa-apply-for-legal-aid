Feature: Bank statement upload

  Background:
    Given csrf is enabled
    And the system is prepped for the employed journey
    And I have completed a non-passported application and reached the open banking consent with bank statement upload enabled
    And the application's applicant is employed and has a matching HMRC response
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
    Then I should be on a page showing "The information on this page has been provided by HMRC"

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
    Then I should be on a page showing "The information on this page has been provided by HMRC"
    Then I should be on a page showing "Do you need to tell us anything else about your client's employment?"

    When I choose "No"
    When I click 'Save and continue'
    Then I should be on a page with title "Which payments does your client receive?"

    When I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page with title "Select payments your client receives in cash"

    When I select 'None of the above'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client receive student finance?"

    When I choose "Yes"
    And I enter amount '5000'
    And I click 'Save and continue'
    Then I should be on a page with title "Which payments does your client make?"

    When I check "Housing payments"
    And I click 'Save and continue'
    Then I should be on a page with title "Select payments your client makes in cash"

    When I select 'Housing payments'
    But I select 'None of the above'
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client have any dependants?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client own the home that they live in?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client own a vehicle?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Which savings or investments does your client have?"

    When I select "Money not in a bank account"
    And I fill "Cash" with "10000"
    And I click 'Save and continue'
    Then I should be on a page with title "Which assets does your client have?"

    When I select 'My client has none of these assets'
    And I click 'Save and continue'
    Then I should be on a page with title "Is your client prohibited from selling or borrowing against their assets?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Select if your client has received payments from these schemes or charities"

    When I select 'England Infected Blood Support Scheme'
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

  @javascript
  Scenario: Checking answers for bank statement upload flow
    Given the feature flag for enable_employed_journey is enabled
    And I have completed a non-passported employed application with bank statement upload as far as the end of the means section
    Then I should be on the 'means_summary' page showing 'Check your answers'

    When I click Check Your Answers Change link for 'bank statements'
    And I upload an evidence file named 'hello_world.pdf'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    And I should see 'hello_world.pdf'
#
#    When I click Check Your Answers Change link for 'employment'
#    Then I should be on a page showing 'This information has been provided by HMRC'
#    When I select 'No'
#    And I click 'Save and continue'
#    Then I should be on the 'means_summary' page showing 'Check your answers'
#    And the answer for 'employment notes' should be 'No'

    When I click Check Your Answers Change link for 'income'
    And I check 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page with title 'Select payments your client receives in cash'
    When I check 'None of the above'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

    When I click Check Your Answers Change link for 'income'
    And I check 'My client receives none of these payments'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

    When I click Check Your Answers Change link for 'outgoings'
    And I check 'Maintenance payments to a former partner'
    And I click 'Save and continue'
    Then I should be on a page with title 'Select payments your client makes in cash'
    When I check 'None of the above'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'

    When I click Check Your Answers Change link for 'outgoings'
    And I check 'My client makes none of these payments'
    And I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
