Feature: partner_means_assessment state benefits handling
  @javascript
  Scenario: I am able to record state benefits received by the partner
    Given csrf is enabled
    And I complete the partner journey as far as 'about financial means'

    When I click 'Save and continue'
    Then I should be on a page with title "What is the partner's employment status?"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Upload the partner's bank statements"

    When I upload the fixture file named "acceptable.pdf"
    Then I should see "acceptable.pdf Uploaded"

    When I click "Save and continue"
    Then I should be on a page with title "Does the partner get any benefits, charitable or government payments?"
    And I choose "Yes"

    When I click "Save and continue"
    Then I should be on a page with title matching "Add benefit, charitable or government payment details"
    And I fill "Description" with "Child benefit"
    And I fill "Amount" with "21.80"
    And I choose "Every week"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does the partner get any other benefits?"
    And I should see "You added 1 benefit, charitable or government payment"
    And I should see "Child benefit"

    When I choose "Yes"
    And I click "Save and continue"

    Then I should be on a page with title matching "Add benefit, charitable or government payment details"
    And I fill "Description" with "The doubt"
    And I fill "Amount" with "52.70"
    And I choose "Every 4 weeks"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does the partner get any other benefits, charitable or government payments?"
    And I should see "You added 2 benefit, charitable or government payments"
    And I should see "Child benefit"
    And I should see "The doubt"

    When I click change for "The doubt"
    Then I should be on a page with title matching "Amend benefit, charitable or government payment details"
    And I fill "Description" with "in kind"

    When I click "Save and continue"
    Then I should be on a page with title matching "Does the partner get any other benefits, charitable or government payments?"
    And I should see "You added 2 benefit, charitable or government payments"
    And I should see "Child benefit"
    And I should see "in kind"
    And I should not see "The doubt"

    When I click remove for "in kind"
    Then I should see "Are you sure you want to remove in kind?"

    When I choose "Yes"
    And I click "Save and continue"

    Then I should be on a page with title matching "Does the partner get any other benefits?"
    And I should see "You added 1 benefit, charitable or government payment"
    And I should see "Child benefit"
    And I should not see "in kind"

    When I choose "No"
    And I click "Save and continue"


  @javascript
  Scenario: I am able to skip state benefits questions when the the partner does not receive them
    Given csrf is enabled
    And I complete the partner journey as far as 'about financial means'

    When I click 'Save and continue'
    Then I should be on a page with title "What is the partner's employment status?"

    When I select "None of the above"
    And I click "Save and continue"
    Then I should be on a page with title "Upload the partner's bank statements"

    When I upload the fixture file named "acceptable.pdf"
    Then I should see "acceptable.pdf Uploaded"

    When I click "Save and continue"
    Then I should be on a page with title "Does the partner get any benefits, charitable or government payments"

    When I choose "No"
    And I click "Save and continue"

    Then I should be on a page with title "Which of these payments does the partner get?"
