Feature: The certification page for an under 18 applicant

  @javascript @vcr
  Scenario: Completes an application to the certification page for applicant that is 17
    Given I have created an application for a 17 year old
    And I should be on the "confirm_client_declaration" page showing "Confirm the following"
    Then I should see "they may have to pay towards legal aid"
    And I should see "their date of birth on the application is correct based on the information you have"
