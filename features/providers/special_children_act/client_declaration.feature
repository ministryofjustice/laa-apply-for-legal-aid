Feature: The certification page for SCA applications

  @javascript @vcr
  Scenario: Completes an application to the certification page for applicant that is 17
    Given I have created an SCA application for a 17 year old
    And I should be on the "confirm_client_declaration" page showing "Confirm the following"
    Then I should not see "they may have to pay towards legal aid"
    And I should see "their date of birth on the application is correct based on the information you have"

  @javascript @vcr
  Scenario: Completes an application to the certification page for applicant that is 28
    Given I have created an SCA application for a 28 year old
    And I should be on the "confirm_client_declaration" page showing "Confirm the following"
    Then I should not see "they may have to pay towards legal aid"
    And I should not see "their date of birth on the application is correct based on the information you have"
