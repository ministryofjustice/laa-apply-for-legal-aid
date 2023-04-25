Feature: partner_means_assessment check your answers
  @javascript @vcr
  Scenario: I am able to add a partner with an address shared with the applicant and then change it
    Given the feature flag for partner_means_assessment is enabled
    And I complete the journey as far as check client details with a partner

    When I click Check Your Answers Change link for 'partner_address'
    Then I should be on a page with title "Is the partner's correspondence address the same as your client's?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Enter the partner's correspondence address"
    And the value of the "address lookup postcode field" input should not be "SW1H 9EA"

    When I enter a postcode 'SW1A 2AA'
    And I click "Find address"
    And I select an address 'Prime Minister & First Lord Of The Treasury, 10 Downing Street, London, SW1A 2AA'
    And I click 'Save and continue'

    Then I should be on a page with title "Check your answers"
    And I should see 'SW1A 2AA'
