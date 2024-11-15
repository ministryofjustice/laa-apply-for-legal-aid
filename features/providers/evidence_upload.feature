@javascript @clamav
Feature: Evidence upload

  Scenario: Uploading a file
    Given csrf is enabled
    When I have completed a non-passported application and reached the evidence upload page
    Then I should be on a page showing 'Upload supporting evidence'
    Then I upload an evidence file named 'hello_world.docx'
    Then I should see 4 uploaded files

  Scenario: Categorising a file and validating that categorising a file is required to proceed
    Given I have completed a non-passported application and reached the evidence upload page
    Then I should see the file 'hello_world.pdf' categorised as 'Uncategorised'
    And I should see the file 'hello_world1.pdf' categorised as 'Uncategorised'
    And I should see the file 'hello_world2.pdf' categorised as 'Uncategorised'

    When I select a category of 'Benefit evidence' for the file 'hello_world.pdf'
    And I select a category of 'Gateway evidence' for the file 'hello_world1.pdf'
    And I click 'Save and continue'
    Then I should see 'Upload supporting evidence'
    And I should see govuk error summary "Select a category for each uploaded file"

    When I select a category of 'Gateway evidence' for the file 'hello_world2.pdf'
    And I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And I should see "Gateway evidence"
    And I should see "Benefit evidence"

  Scenario: Deleting a file
    When I have completed a non-passported application and reached the evidence upload page
    Then I should be on a page showing 'Upload supporting evidence'

    When I click delete for the file 'hello_world.pdf'
    Then I should see 'has been successfully deleted'
    And I should see 2 uploaded files

  Scenario: Categorising a file and then deleting another does not lose that categorisation
    Given I have completed a non-passported application and reached the evidence upload page
    Then I should see the file 'hello_world.pdf' categorised as 'Uncategorised'
    And I should see the file 'hello_world1.pdf' categorised as 'Uncategorised'
    And I should see the file 'hello_world2.pdf' categorised as 'Uncategorised'

    When I select a category of 'Benefit evidence' for the file 'hello_world.pdf'
    When I select a category of 'Gateway evidence' for the file 'hello_world2.pdf'
    And I click delete for the file 'hello_world1.pdf'
    Then I should see 'has been successfully deleted'
    Then I should see the file 'hello_world.pdf' categorised as 'Benefit evidence'
    And I should see the file 'hello_world2.pdf' categorised as 'Gateway evidence'

  Scenario: Categorising a file and then uploading another does not lose that categorisation
    Given I have completed a non-passported application and reached the evidence upload page
    Then I should see the file 'hello_world.pdf' categorised as 'Uncategorised'
    And I should see the file 'hello_world1.pdf' categorised as 'Uncategorised'
    And I should see the file 'hello_world2.pdf' categorised as 'Uncategorised'

    When I select a category of 'Benefit evidence' for the file 'hello_world.pdf'
    And I select a category of 'Gateway evidence' for the file 'hello_world1.pdf'
    And I select a category of 'Gateway evidence' for the file 'hello_world2.pdf'

    When I upload an evidence file named 'hello_world.docx'
    Then I should see 4 uploaded files
    And I should see the file 'hello_world.pdf' categorised as 'Benefit evidence'
    And I should see the file 'hello_world1.pdf' categorised as 'Gateway evidence'
    And I should see the file 'hello_world2.pdf' categorised as 'Gateway evidence'
    And I should see the file 'hello_world.docx' categorised as 'Uncategorised'
