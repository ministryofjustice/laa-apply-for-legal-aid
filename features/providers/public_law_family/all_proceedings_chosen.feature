Feature: All available proceedings have been selected

  @javascript @vcr
  Scenario: When I see the has_other_proceedings page
    Given I have started an application, added all available PLF proceedings, and reached the proceedings list
    Then I should see "No more proceedings can be added to the ones you have chosen"

    When I click "Save and continue"
    Then I should be on a page with title "Placement order - parent or parental responsibility"
    Then I should see "Proceeding 1 of 4"
