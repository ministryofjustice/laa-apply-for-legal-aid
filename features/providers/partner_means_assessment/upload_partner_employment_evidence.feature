Feature: Check partner employment evidence upload
  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to upload evidence where the client and partner both have additional employment information
    Given I am logged in as a provider
    And csrf is enabled
    And I have completed an application where client and partner are both employed and "both" have additional information
    And I visit "uploaded evidence collection"

    Then I should see "Use this page to upload:"
    And I should see "evidence of your client's employment"
    And I should see "evidence of the partner's employment"

    When I click "Save and continue"
    Then I should see "Upload your client's employment evidence"
    Then I should see "Upload the partner's employment evidence"

    When I upload an evidence file named 'hello_world.pdf'
    And I sleep for 2 seconds
    And I select a category of "Client's employment evidence" for the file 'hello_world.pdf'
    When I upload an evidence file named 'hello_world1.pdf'
    And I sleep for 2 seconds
    And I select a category of "Partner's employment evidence" for the file 'hello_world1.pdf'
    And I click 'Save and continue'

  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to upload evidence where only the partner has additional employment information
    Given I am logged in as a provider
    And csrf is enabled
    And I have completed an application where client and partner are both employed and "partner" has additional information
    And I visit "uploaded evidence collection"

    Then I should see "Use this page to upload evidence of the partner's employment"
