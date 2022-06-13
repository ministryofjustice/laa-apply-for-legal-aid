@javascript @vcr
Feature: Statement of case upload

  Background:
    Given csrf is enabled
    And I have completed the non-passported means assessment and start the merits assessment
    Then I should be on the 'merits_task_list' page showing 'Statement of case\nNOT STARTED'
    When I click link "Statement of case"
    Then I should be on a page with title "Provide a statement of case"

  Scenario: Uploading a statement of case containing no content
    When I upload the fixture file named 'empty_file.pdf'
    Then I should see govuk error summary "empty_file.pdf has no content"

  Scenario: Uploading a statement of case containing a virus
    When I upload the fixture file named 'malware.doc'
    Then I should see govuk error summary "malware.doc contains a virus"

  Scenario: Uploading a statement of case with unacceptable content type
    When I upload the fixture file named 'zip.zip'
    Then I should see govuk error summary "zip.zip is not a valid file type"
