Feature: Change applicant email address
  @javascript @vcr
  Scenario: I want to change the email address from the about financial assessment page
    Given I complete the journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit. Is this correct?"
    When I click "Yes, continue"
    Then I should be on a page showing 'What you need to do'
    When I click "Continue"
    And I should be on a page showing "What is your client's employment status?"
    And I select "None of the above"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client use online banking?"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title 'Share bank statements with online banking'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title "Enter your client's email address"
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    And I click link 'Change'
    Then I should be on a page showing 'Email address'
    Then I fill 'email' with 'testagain@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I should be on a page showing 'testagain@test.com'

  @javascript @vcr
  Scenario: I want to change the applicant email address once the email has been sent
    Given I complete the journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not get a passporting benefit. Is this correct?"
    When I click "Yes, continue"
    Then I should be on a page showing 'What you need to do'
    When I click 'Continue'
    And I should be on a page showing "What is your client's employment status?"
    And I select "None of the above"
    When I click 'Save and continue'
    Then I should be on a page with title "Does your client use online banking?"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title 'Share bank statements with online banking'
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter your client's email address"
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    And I should see 'test@test.com'
    When I click 'Send link'
    Then I should be on a page showing "We've shared your application with your client"
    And I should see "We've sent an email to test@test.com"
    When I click link 'Change email and resend link'
    Then I should be on a page showing "Enter your client's email address"
    Then I fill 'email' with 'testagain@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    And I should see 'testagain@test.com'
    When I click 'Send link'
    Then I should be on a page showing "We've shared your application with your client"
    And I should see "We've sent an email to testagain@test.com"
    When I click link 'Back to your applications'
    Then I am on the legal aid applications page
    When I click link 'In progress'
    And I click link 'Test User'
    Then I should be on the 'check_provider_answers' page showing 'Your client needs to complete their part of the application before you can continue.'
    And I should see "We've sent an email to testagain@test.com'
    When I click link 'Change email and resend link'
    Then I should be on a page showing "Enter your client's email address"
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    And I should see 'test@test.com'
    When I click 'Send link'
    Then I should be on a page showing "We've shared your application with your client"
    And I should see "We've sent an email to test@test.com"

