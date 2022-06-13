@javascript
Feature: Statement of case upload

  @vcr
  Scenario: Uploading a statement of case containing no content (zero bytes)
    Given csrf is enabled
    And I have completed the non-passported means assessment and start the merits assessment
    Then I should be on the 'merits_task_list' page showing 'Statement of case\nNOT STARTED'

    When I click link "Statement of case"
    Then I should be on a page with title "Provide a statement of case"
    When I upload the fixture file named 'empty_file.pdf'
    And I sleep for 2 seconds
    Then I should see govuk error summary "empty_file.pdf has no content"
