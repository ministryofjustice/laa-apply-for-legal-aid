@javascript @clamav
Feature: Bank statement file upload

  Scenario: Uploading a file
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

    When I upload the fixture file named 'empty_file.pdf'
    Then I should see govuk error summary "empty_file.pdf has no content"

    When I upload the fixture file named 'malware.doc'
    Then I should see govuk error summary "malware.doc contains a virus"

    When I upload the fixture file named 'zip.zip'
    Then I should see govuk error summary "zip.zip is not a valid file type"

    When I upload the fixture file named 'too_large.pdf'
    Then I should see govuk error summary "too_large.pdf is larger than 7MB"

    When I click 'Save and continue'
    Then I should be on a page with title "Upload the partner's bank statements"
    And I should see govuk error summary "Upload the partner's bank statements"

    When I upload the fixture file named 'acceptable.pdf'
    Then I should see 'acceptable.pdf Uploaded'

    When I click 'Save and continue'
    Then I should be on a page with title matching "HMRC has no record of the partner's employment in the last 3 months"

    When I click link "Back"
    Then I should be on a page with title "Upload the partner's bank statements"
    And I should see 'acceptable.pdf Uploaded'

    When I click 'Save and come back later'
    Then I should be on a page with title "Your applications"

  Scenario: Deleting a file
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

    Given I upload the fixture file named 'acceptable.pdf'
    And I upload an evidence file named 'hello_world.pdf'
    And I upload an evidence file named 'hello_world.docx'
    Then I should see 'acceptable.pdf Uploaded'
    And I should see 'hello_world.pdf Uploaded'
    And I should see 'hello_world.docx Uploaded'

    When I click delete for the file 'hello_world.pdf'
    Then I should see 'hello_world.pdf has been successfully deleted'
    And I should see 'acceptable.pdf Uploaded'
    And I should see 'hello_world.docx Uploaded'
