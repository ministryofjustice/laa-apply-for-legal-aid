Feature: Employment status

  @javascript @vcr
  Scenario: Client employment status page behaves as expected
    Given I complete the non-passported journey as far as check your answers
    Then I should be on a page showing 'Check your answers'

    When I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you need to do"

    When I click 'Continue'
    Then I should be on a page with title "What is your client's employment status?"

    # Test that no checkbox is prefilled
    When I click "Save and continue"
    Then I should see govuk error summary "Select one or more employment types or None of the above if not employed"

    # Test that existing values are represented by checkboxes
    When I select "Employed"
    And I click "Save and continue"
    And I click link "Back"
    Then I should be on a page with title "What is your client's employment status?"
    And I should see the following checkboxes checked or unchecked:
      | checkbox_id | checked |
      | applicant-employed-true-field | true |
      | applicant-self-employed-true-field | false |
      | applicant-armed-forces-true-field | false |

    When I click "Save and continue"
    Then I should be on a page with title "Does your client use online banking?"

  @javascript @vcr
  Scenario: Partner employment status page behaves as expected
    Given I complete the non-passported journey as far as the employment status page for a partner
    Then I should be on a page with title "What is the partner's employment status?"

    # Test that no checkbox is prefilled
    When I click "Save and continue"
    Then I should see govuk error summary "Select one or more employment types or None of the above if not employed"

    # Test that existing values are represented by checkboxes
    When I select "Employed"
    And I click "Save and continue"
    And I click link "Back"
    Then I should be on a page with title "What is the partner's employment status?"
    And I should see the following checkboxes checked or unchecked:
      | checkbox_id | checked |
      | partner-employed-true-field | true |
      | partner-self-employed-true-field | false |
      | partner-armed-forces-true-field | false |

    When I click "Save and continue"
    Then I should be on a page with title "Upload the partner's bank statements"
