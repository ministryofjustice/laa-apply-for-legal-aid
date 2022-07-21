Feature: Bank statement upload

  @javascript
  Scenario: Uploading a file
    Given csrf is enabled
    And I have completed a non-passported application and reached the open banking consent with bank statement upload enabled
    And I should be on a page showing "Does your client use online banking?"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Upload bank statements"
    And the page is accessible

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

    Given csrf is enabled
    And I have completed a non-passported application and reached the open banking consent with bank statement upload enabled
    And I should be on a page showing "Does your client use online banking?"

    When I choose 'No'
    And I click 'Save and continue'
    Then I should be on a page with title "Upload bank statements"
    And the page is accessible

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
