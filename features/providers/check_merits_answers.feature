Feature: Check merits answers
  @javascript @vcr
  Scenario: Checking passported answers for an application with multiple procedings
    Given I complete the journey as far as check passported answers with multiple proceedings
    Then I should be on a page showing "Fake gateway evidence file"
    Then I should be on a page showing "Fake file name 1 (15.7 KB)"
    Then I should be on a page showing "Statement of case text entered here"

  @javascript
  Scenario: On an SCA application where a proceeding has no questions on the merits task list
    Given I complete the journey as far as check merits answers with an SCA proceeding without merits tasks
    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Case details |
      | h2  | Opponent details |
    And the following sections should not exist:
      | tag | section |
      | h2  | Supervision order |
