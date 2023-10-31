Feature: Check partner employment evidence upload
  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to upload evidence where the client and partner both have additional employment information
    Given the feature flag for partner_means_assessment is enabled
    And I am logged in as a provider
    And csrf is enabled
    And I have completed an application where client and partner are both employed and "both" have additional information
    And I visit "uploaded evidence collection"

    Then I should see "Use this page to upload:"
    And I should see "evidence of your client's employment status"
    And I should see "evidence of the partner's employment status"

  @javascript @vcr @hmrc_use_dev_mock
  Scenario: I am able to upload evidence where only the partner has additional employment information
    Given the feature flag for partner_means_assessment is enabled
    And I am logged in as a provider
    And csrf is enabled
    And I have completed an application where client and partner are both employed and "partner" has additional information
    And I visit "uploaded evidence collection"

    Then I should see "Use this page to provide evidence of the partner's employment status"
