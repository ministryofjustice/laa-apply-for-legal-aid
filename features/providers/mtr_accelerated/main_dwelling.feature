Feature: Main dwelling place changes for MTR-Accelerated measures
# TODO: AP-5493 - This whole file can probably be deleted after the MTR-A feature flag is removed

  @javascript
  Scenario: When the MTR-A feature flag is on and the client has no partner I should see the legacy pages
    Given I previously created a passported application with no assets and left on the "check_passported_answers" page

    When I visit the in progress applications page
    And I view the previously created application
    Then I am on the check your answers page for other assets

    When I click Check Your Answers Change link for 'property_ownership'
    Then I should be on a page showing "Does your client own the home they usually live in?"
    And I should see "This is where your client normally lives, even if they have temporarily left their home due to domestic abuse."

    When I choose "Yes, with a mortgage or loan"
    Then I click "Save and continue"
    Then I should be on a page showing "Your client's home"
    And I should see "How much is the home they usually live in worth?"

    When I click link 'Back'
    And I choose "Yes, owned outright"
    Then I click "Save and continue"
    Then I should be on a page showing "Your client's home"
    And I should see "How much is the home they usually live in worth?"

  @javascript
  Scenario: When the MTR-A feature flag is on and the client a partner I should see the legacy pages
    Given I complete the journey as far as check client details with a partner

    When I click "Save and continue"
    Then I should be on a page with title "DWP records show that your client does not get a passporting benefit"

    When I click "Continue"
    Then I should be on a page showing "Does your client get a passporting benefit?"
    When I choose "Yes, they get a passporting benefit with a partner"

    And I click "Save and continue"
    Then I should be on a page with title "Check your client's and their partner's details"

    When I click "Save and continue"
    Then I should be on a page with title "Which joint passporting benefit does your client and their partner get?"

    When I choose "Universal Credit"
    And I click "Save and continue"
    Then I should be on a page with title "Do you have evidence that your client is covered by their partner's Universal Credit?"

    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page with title "What you need to do"

    When I click "Continue"
    Then I should be on a page with title "Does your client or their partner own the home your client usually lives in?"
    And I should see "This is where your client normally lives, even if they have temporarily left their home due to domestic abuse."

    When I choose "Yes, with a mortgage or loan"
    Then I click "Save and continue"
    Then I should be on a page showing "Your client's home"
    And I should see "How much is the home worth where your client and their partner usually live?"

    When I click link 'Back'
    And I choose "Yes, owned outright"
    Then I click "Save and continue"
    Then I should be on a page showing "Your client's home"
    And I should see "How much is the home worth where your client and their partner usually live?"
