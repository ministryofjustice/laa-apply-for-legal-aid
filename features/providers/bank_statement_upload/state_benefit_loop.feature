Feature: Bank statement upload journey state_benefit loop feature
  @javascript
  Scenario: I can add multiple state benefits for a non-passported, non-TrueLayer applications on behalf of employed clients
    Given csrf is enabled
    And I have completed a non-passported employed application with bank statements as far as the open banking consent page
    Then I should be on a page showing "Does your client use online banking?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Upload your client's bank statements"

    Given I upload the fixture file named "acceptable.pdf"
    And I upload an evidence file named "hello_world.pdf"
    Then I should see "acceptable.pdf Uploaded"
    And I should see "hello_world.pdf Uploaded"

    When I click "Save and continue"
    Then I should be on a page with title matching "Review .*'s employment income"
    And I should be on a page showing "Do you need to tell us anything else about your client's employment?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title matching "Does your client get any benefits, charitable or government payments?"
    And I choose "Yes"

    When I click "Save and continue"
    Then I should be on a page with title matching "Add benefit, charitable or government payment details"
    And I fill "Description" with "Child benefit"
    And I fill "Amount" with "21.80"
    And I choose "Every week"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does your client receive any other benefits?"
    And I should see "You added 1 benefit, charitable or government payment"
    And I should see "Child benefit"

    When I choose "Yes"
    And I click "Save and continue"

    Then I should be on a page with title matching "Add benefit, charitable or government payment details"
    And I fill "Description" with "The doubt"
    And I fill "Amount" with "52.70"
    And I choose "Every 4 weeks"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does your client receive any other benefits, charitable or government payments?"
    And I should see "You added 2 benefit, charitable or government payments"
    And I should see "Child benefit"
    And I should see "The doubt"

    When I click change for "The doubt"
    Then I should be on a page with title matching "Amend benefit, charitable or government payment details"
    And I fill "Description" with "in kind"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does your client receive any other benefits, charitable or government payments?"
    And I should see "You added 2 benefit, charitable or government payments"
    And I should see "Child benefit"
    And I should see "in kind"
    And I should not see "The doubt"

    When I click remove for "in kind"
    Then I should see "Are you sure you want to remove in kind?"

    When I choose "Yes"
    And I click "Save and continue"

    Then I should be on a page with title matching "Does your client receive any other benefits?"
    And I should see "You added 2 benefit, charitable or government payments"
    And I should see "Child benefit"
    And I should not see "in kind"

    When I choose "No"
    And I click "Save and continue"

    Then I should be on a page with title matching "Which of these payments does your client get?"
    When I select "My client does not get any of these payments"
    And I click "Save and continue"

    Then I should be on a page with title "Does your client get student finance?"
    When I choose "No"
    And I click "Save and continue"

    Then I should be on a page with title matching "Which of these payments does your client pay?"
    When I select "My client makes none of these payments"
    And I click "Save and continue"

    Then I should be on a page with title matching "Does your client have any dependants?"
    When I choose "No"
    And I click "Save and continue"

    Then I should be on a page with title matching "Check your answers"
    And I should see "Child benefit"
    And I should see "£21.80"
    And I should see "Every week"
