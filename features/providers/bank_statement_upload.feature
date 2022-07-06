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
    # TODO: placeholder as flow will change in future iterations
    Then I should be on a page with title "Check your answers"

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
