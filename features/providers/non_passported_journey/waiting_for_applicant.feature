Feature: non_passported_journey waiting for applicant
  @javascript
  Scenario: I want the check_provider_answers page to correctly display while waiting for client to provide data
    Given I start the application with a negative benefit check result
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit. Is this correct?"
    When I click "Yes, continue"
    Then I should be on a page showing "What you need to do"
    When I click 'Continue'
    Then I should be on a page showing "What is your client's employment status?"
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page with title "Does your client use online banking?"
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page with title "Share bank statements with online banking"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on the 'email_address' page showing "Enter your client's email address"
    When I enter the email address 'test@example.com'
    And I click 'Save and continue'
    Then I should be on the 'about_the_financial_assessment' page showing 'Send your client a link to access the service'
    When I click 'Send link'
    Then I should be on the 'application_confirmation' page showing "We've shared your application with your client"
    When I visit the in progress applications page
    And I view the first application in the table
    Then I should be on the 'check_provider_answers' page showing 'Your application'
    And I should not see 'What happens next'
    But I should see 'Your client needs to complete their part of the application before you can continue.'
    Then the following sections should exist:
      | tag | section |
      | h3  | Client details |

    And the "Client details" check your answers section should contain:
      | Employment status | Not employed |
