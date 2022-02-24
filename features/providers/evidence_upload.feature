Feature: Evidence upload

  @javascript @vcr
  Scenario: Uploading a file
    Given csrf is enabled
    When I have completed a non-passported application and reached the evidence upload page
    Then I should be on a page showing 'Upload supporting evidence'
    Then I upload an evidence file named 'hello_world.docx'
    Then I should see 4 uploaded files

  @javascript @vcr
  Scenario: Categorising a file and validating that categorising a file is required to proceed
    When I have completed a non-passported application and reached the evidence upload page
    Then I should be on a page showing 'Uncategorised'
    Then I should be able to categorise 'hello_world.pdf' as 'Benefit evidence'
    Then I should be able to categorise 'hello_world1.pdf' as 'Gateway evidence'
    When I click 'Save and continue'
    Then I should see 'Upload supporting evidence'
    And I should see 'Select a category for each uploaded file'

  @javascript @vcr
  Scenario: Deleting a file
    When I have completed a non-passported application and reached the evidence upload page
    Then I should be on a page showing 'Upload supporting evidence'
    Then I should be able to delete 'hello_world.pdf'
    Then I should see 'has been successfully deleted'
    And I should see 2 uploaded files
