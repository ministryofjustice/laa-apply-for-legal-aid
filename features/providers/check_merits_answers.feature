Feature: Check merits answers
  @javascript @vcr
  Scenario: Checking passported answers for an application with multiple procedings
    Given I complete the journey as far as check passported answers with multiple proceedings
    Then I should be on a page showing "Fake gateway evidence file (15.7 KB)"
    Then I should be on a page showing "Fake file name 1 (15.7 KB)"
    Then I should be on a page showing "Statement of case text entered here"
