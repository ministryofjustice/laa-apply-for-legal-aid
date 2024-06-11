Feature: partner_means_assessment dwp override
  @javascript @vcr
  Scenario: I am able to override the dwp result for a client who receives a joint passporting benefit with their partner
    Given I complete the journey as far as check client details with a partner

    When I click 'Save and continue'
    Then I should be on a page with title "DWP records show that your client does not get a passporting benefit"

    When I choose "No, my client gets a joint passporting benefit with their partner"
    And I click 'Save and continue'
    Then I should be on a page with title "Check your client's and their partner's details"

    When I click link "Change Partner name"
    Then I should be on a page with title "Enter the partner's details"

    When I fill "First name" with "Partner"
    And I fill "Last name" with "Changed"
    And I enter the date of birth '01-01-2001'
    And I choose "Yes"
    And I enter National insurance number "AB123456A"
    And I click "Save and continue"
    Then I should be on a page with title "Check your client's and their partner's details"
    And I should see "Partner Changed"
    And I should see "1 January 2001"
    And I should see "AB123456A"
