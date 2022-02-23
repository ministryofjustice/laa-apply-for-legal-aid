Feature: Evidence upload

  @javascript @vcr
  Scenario: Categorising a file and validating that categorising a file is required to proceed
    When I have completed a non-passported application and reached the evidence upload page
    Then I should be on a page showing 'Uncategorised'
    Then I should be able to categorise 'hello_world.pdf' as 'Benefit evidence'
    Then I should be able to categorise 'hello_world1.pdf' as 'Gateway evidence'
    When I click 'Save and continue'
    Then I should see 'Upload supporting evidence'
    And I should see 'Select a category for each uploaded file'
