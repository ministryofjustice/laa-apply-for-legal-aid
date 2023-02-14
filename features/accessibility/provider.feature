Feature: Provider accessibility

  @javascript @vcr
  Scenario: I start a new non-passported application and enter client details
    Given I am logged in as a provider
    Then I visit the application service
    And the page is accessible
    Then I click link "Start"
    And the page is accessible
    Then I click link "Make a new application"
    And the page is accessible
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    And the page is accessible
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    And the page is accessible
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    And the page is accessible
    Then I enter a postcode 'SW1H 9EA'
    Then I click find address
    Then I select an address 'Transport For London, 98 Petty France, London, SW1H 9EA'
    Then I click 'Save and continue'
    Then I should be on the 'proceedings_types' page showing 'Search for legal proceedings'
    And the page is accessible
    Then I search for proceeding 'Non-molestation order'
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    And the page is accessible
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client’s role in this proceeding?'
    And the page is accessible
    When I choose 'Applicant/claimant/petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    And the page is accessible
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    And the page is accessible
    When I choose 'No'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\n'
    And I should see 'You cannot change the default level of service for the substantive application for this proceeding'
    And I click 'Save and continue'
    Then I should see 'For the substantive application, select the scope'
    When I select 'Hearing'
    And I enter the 'proceeding hearing date CV118' date of 2 months in the future
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "default substantive cost limit"
    And the page is accessible
    When I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"
    And the page is accessible
    And I choose "Yes"
    And I enter national insurance number 'CB987654A'
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not receive a passporting benefit"
    And the page is accessible

  @javascript @vcr
  Scenario: I complete the financial assessment eligibility section for a non-passported application
    Given I complete the non-passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "DWP records show that your client does not receive a passporting benefit"
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing "What is your client's employment status?"
    And the page is accessible
    When I select 'None of the above'
    And I click 'Save and continue'
    Then I should be on a page with title "We need your client's bank statements from the last 3 months"
    And the page is accessible
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title 'Share bank statements with online banking'
    And the page is accessible
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page with title "Enter your client's email address"
    And the page is accessible
    And I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Send your client a link to access the service'
    And the page is accessible
    When I click 'Send link'
    Then I should be on a page showing "We've shared your application with your client"
    And the page is accessible
    When I click link 'Back to your applications'
    Then I should be on a page showing 'Applications'
    And the page is accessible

  @javascript @vcr
  Scenario: I complete the non-passported means assessment and it is accessible
    Given I start the means application and the applicant has uploaded transaction data
    Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
    And the page is accessible
    Then I click 'Continue'
    Then I should be on a page showing "Which payments does your client receive?"
    And the page is accessible
    When I select 'Benefits'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client receives in cash"
    And the page is accessible
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on a page showing "Does your client receive student finance?"
    And the page is accessible
    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page showing "Which payments does your client make?"
    And the page is accessible
    When I select 'Housing payments'
    And I click 'Save and continue'
    Then I should be on a page showing "Select payments your client makes in cash"
    And the page is accessible
    When I select "None of the above"
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Sort your client's income into categories"
    And the page is accessible
    And I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select any benefits your client got in the last 3 months'
    And the page is accessible
    Then I select the first checkbox
    And I click 'Save and continue'
    And I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Sort your client's regular payments into categories"
    And the page is accessible
    Then I click the first link 'View statements and add transactions'
    Then I should be on a page showing 'Select housing payments'
    And the page is accessible
    Then I select the first checkbox
    And I click 'Save and continue'
    Then the page is accessible
    Then I click 'Save and continue'
    Then I should be on the 'dependants' page showing "Does your client have any dependants?"
    And the page is accessible
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Enter dependant details'
    And the page is accessible
    Given I add the details for a child dependant
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client have any other dependants?"
    And the page is accessible
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'check_income_answers' page showing 'Check your answers'
    When I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    And the page is accessible
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "How much is your client's home worth?"
    And the page is accessible
    Then I fill "Property value" with "200000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    And the page is accessible
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own their home with anyone else?"
    And the page is accessible
    Then I choose "Yes, a partner or ex-partner"
    Then I click 'Save and continue'
    Then I should be on a page showing "What % share of their home does your client legally own?"
    And the page is accessible
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    And the page is accessible
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "What is the estimated value of the vehicle?"
    And the page is accessible
    Then I fill "Estimated value" with "4000"
    And I click "Save and continue"
    Then I should be on a page showing "Are there any payments left on the vehicle?"
    And the page is accessible
    Then I choose "Yes"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "Was the vehicle bought over 3 years ago?"
    And the page is accessible
    Then I choose 'Yes'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    And the page is accessible
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "Your client’s bank accounts"
    And the page is accessible
    Then I choose 'Yes'
    Then I should be on a page showing 'Enter the total amount in all accounts.'
    And the page is accessible
    Then I fill 'Offline savings accounts' with '3000'
    And I click 'Save and continue'
    Then I should be on a page showing "Which savings or investments does your client have?"
    And the page is accessible
    Then I select "My client has none of these savings or investments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which assets does your client have?"
    And the page is accessible
    Then I select "Any valuable items worth £500 or more"
    And I fill 'Valuable items value' with '600'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Is there anything else you need to tell us about your client’s assets?'
    And the page is accessible
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on the 'policy_disregards' page showing 'schemes or charities'
    Then I select 'England Infected Blood Support Scheme'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on the 'check_capital_answers' page showing 'Check your answers'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on the 'capital_income_assessment_result' page showing 'How we calculated your client\'s financial eligibility'
    And the page is accessible
    Then I click 'Save and continue'

  @javascript @vcr
  Scenario: I complete the client details section of a passported application and it is accessible
    Given I complete the passported journey as far as check your answers for client details
    Then I should be on a page showing 'Check your answers'
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing 'DWP records show that your client receives a passporting benefit'
    And the page is accessible

  @javascript @vcr
  Scenario: I complete the non-passported merits assessment and it is accessible
    Given I have completed the non-passported means assessment and start the merits assessment
    Then I should be on the 'merits_task_list' page showing 'Latest incident details\nNOT STARTED'
    When I click link 'Latest incident details'
    Then I should be on a page showing 'Latest incident details'
    And I should be on a page showing 'When did your client contact you about the latest domestic abuse incident?'
    And the page is accessible
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent's name"
    And the page is accessible
    When I fill "First Name" with "John"
    And I fill "Last Name" with "Doe"
    When I click 'Save and continue'
    Then I should be on a page showing "Do all parties have the mental capacity to understand the terms of a court order?"
    And the page is accessible
    When I choose "Yes"
    And I click 'Save and continue'
    Then I should be on a page showing "Domestic abuse summary"
    And the page is accessible
    Then I choose option "Application merits task opponent warning letter sent True field"
    Then I choose option "Application merits task opponent police notified True field"
    Then I choose option "Application merits task opponent bail conditions set True field"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide a statement of case"
    And the page is accessible
    Then I fill "Application merits task statement of case statement field" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success\nNOT STARTED'
    When I click the last link 'Chances of success'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    And the page is accessible
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    And the page is accessible
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on the 'merits_task_list' page showing 'Chances of success\nCOMPLETED'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the page is accessible
    Then I click 'Save and continue'
    Then I should be on a page showing "Confirm the following"
    And the page is accessible
    Then I check "I confirm the above is correct and that I'll get a signed declaration from my client"
    Then I click 'Save and continue'
    Then I should be on a page showing "Review and print your application"
    And the page is accessible
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    And the page is accessible
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And the page is accessible
