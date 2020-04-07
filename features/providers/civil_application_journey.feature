Feature: Civil application journeys
  @javascript
  Scenario: I am able to return to my legal aid applications
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    And I click link "Apply for legal aid"
    Then I am on the legal aid applications

  @javascript
  Scenario: I am able to select an office
    Given I am logged in as a provider
    Then I visit the select office page
    Then I choose 'London'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

  @javascript
  Scenario: I am able to confirm my office
    Given I am logged in as a provider
    Given I have an existing office
    Then I visit the confirm office page
    Then I choose 'Yes'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Your applications'

  @javascript
  Scenario: I am able to change my registered office
    Given I am logged in as a provider
    Given I have an existing office
    Then I visit the confirm office page
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing 'office handling this application'

  @javascript @vcr
  Scenario: No results returned is seen on screen when invalid proceeding search entered
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3 Lonsdale Road, Bexleyheath, DA7 4NG'
    Then I click 'Save and continue'
    When the search for "cakes" is not successful
    Then the result list on page returns a "No results found." message

  @javascript @vcr
  Scenario: I am able to clear proceeding on the proceeding page
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3 Lonsdale Road, Bexleyheath, DA7 4NG'
    Then I click 'Save and continue'
    And I search for proceeding 'app'
    Then proceeding suggestions has results
    When I click clear search
    Then the results section is empty
    Then proceeding search field is empty

  @javascript @vcr
  Scenario: I am able to select multiple proceeding types
    Given I skip the rest of this scenario until multiple proceeding types are supported
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3 Lonsdale Road, Bexleyheath, DA7 4NG'
    Then I click 'Save and continue'
    Then I expect to see 0 proceeding types selected
    And I search for proceeding 'app'
    Then proceeding suggestions has results
    When I select proceeding type 3
    Then I expect to see 1 proceeding types selected
    And I search for proceeding 'child'
    When I select proceeding type 1
    Then I expect to see 2 proceeding types selected
    When I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I complete each step up to the applicant page
    # testing shared steps: Given I start the journey as far as the applicant page
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    Then I should be on the 'providers/declaration' page showing 'Declaration'
    When I click 'Agree and continue'
    Then I should be on the Applicant page

  @javascript @vcr @webhint
  Scenario: Completes the application using address lookup
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3 Lonsdale Road, Bexleyheath, DA7 4NG'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Covered under a substantive certificate'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I click 'Save and continue'
    Then I am on the client use online banking page
    Then I select 'Your client uses online banking for all of their bank accounts'
    Then I select 'Your client agrees to share their financial data with us'
    Then I click 'Save and continue'
    Then I am on the Email Entry page
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I click 'Send client link'
    Then I am on the application confirmation page

  @localhost_request @javascript @vcr
  Scenario: Completes the application using manual address
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9AJ'
    Then I click find address
    Then I enter address line one '102 Petty France'
    Then I enter city 'London'
    Then I enter postcode 'SW1H 9AJ'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I am on the client use online banking page
    Then I select 'Your client uses online banking for all of their bank accounts'
    Then I select 'Your client agrees to share their financial data with us'
    Then I click 'Save and continue'
    Then I am on the Email Entry page
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I click 'Send client link'
    Then I am on the application confirmation page

  @javascript @vcr
  Scenario: I can see that the applicant receives benefits
    Given I start the journey as far as the applicant page
    And a "bank holiday" exists in the database
    Then I enter name 'Test', 'Walker'
    Then I enter the date of birth '10-01-1980'
    Then I enter national insurance number 'JA293483A'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3 Lonsdale Road, Bexleyheath, DA7 4NG'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'Yes'
    Then I enter the 'used delegated functions' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Covered under an emergency certificate"
    Then I should be on a page showing "Covered under a substantive certificate"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I should be on a page showing 'Covered under an emergency certificate'
    Then I should be on a page showing 'Covered under a substantive certificate'
    Then I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'

  @javascript @vcr
  Scenario: I can see that the applicant does not receive benefits
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Paul'
    Then I enter the date of birth '10-12-1961'
    Then I enter national insurance number 'JA293483B'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3 Lonsdale Road, Bexleyheath, DA7 4NG'
    Then I click 'Save and continue'
    Then I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "Covered under a substantive certificate"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"

  @javascript @vcr
  Scenario: I want to change first name from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'First name'
    Then I enter the first name 'Bartholomew'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'First name' should be 'Bartholomew'

  @javascript @vcr
  Scenario: I want to return to the check your answers page without changing first name
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'First name'
    Then I click link "Back"
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change the proceeding type from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Proceeding Type'
    And I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Have you used delegated functions?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to return to the check your answers page without changing proceeding type
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Proceeding Type'
    And I search for proceeding 'Non-molestation order'
    Then proceeding suggestions has results
    Then I click link "Back"
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to return to the check your answers page without changing name
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'First name'
    Then I click link "Back"
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change address from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Address'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3 Lonsdale Road, Bexleyheath, DA7 4NG'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change address manually from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Address'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9AJ'
    Then I click find address
    Then I enter address line one '102 Petty France'
    Then I enter city 'London'
    Then I enter postcode 'SW1H 9AJ'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change email address from the about financial assessment page
    Given I complete the journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing "We need to check your client's financial eligibility"
    Then I click 'Continue'
    Then I should be on a page showing 'Check if you can continue using this service'
    Then I select 'Your client uses online banking for all of their bank accounts'
    Then I select 'Your client agrees to share their financial data with us'
    Then I click 'Save and continue'
    Then I am on the Email Entry page
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    And I click link 'Change'
    Then I should be on a page showing 'Email address'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I should be on a page showing 'test@test.com'

  @javascript @vcr
  Scenario: I want to return to check your answers from address lookup
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Address'
    Then I am on the postcode entry page
    Then I click link "Back"
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to return to check your answers from address select
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Address'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I click link "Back"
    Then I click link "Back"
    Then I should be on a page showing 'Check your answers'

  Scenario: I navigate to Contact page from application service and back
    Given I am logged in as a provider
    Given I visit the application service
    Then I click link "Contact"
    Then I should be on a page showing "Contact us"
    Then I click link "Back"
    Then I should be on a page showing "Apply for legal aid"

  @javascript
  Scenario: I want to return to applicant from Contact page
    Given I start the journey as far as the applicant page
    Then I click link "Contact"
    Then I should be on a page showing "Contact us"
    Then I click link "Back"
    Then I should be on the Applicant page

  @javascript @vcr
  Scenario: I am able to view the client completed means answers
    Given I start the merits application and the applicant has uploaded transaction data
    Then I should be on a page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Your client's income"
    When I click link 'Add another type of income'
    And I select 'Benefits like Universal Credit or Child Benefit'
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Your client's income"
    When I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Your client's regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    Then I click link 'View/change declared income'
    Then I should be on a page showing "Your client's income"
    Then I click 'Save and continue'
    Then I should be on the 'means_summary' page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'

  @javascript @vcr
  Scenario: Completes the merits application for applicant that does not receive passported benefits
    Given I start the merits application and the applicant has uploaded transaction data
    Then I should be on a page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on the 'income_summary' page showing "Your client's income"
    When I click link 'Add another type of income'
    And I select 'Benefits like Universal Credit or Child Benefit'
    And I click 'Save and continue'
    Then I should be on the 'income_summary' page showing "Your client's income"
    And I click 'Save and continue'
    Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on the 'outgoings_summary' page showing "Your client's regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "None of these"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client tell you about the latest domestic abuse incident?'
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    Then I choose option "Respondent understands terms of court order True"
    Then I choose option "Respondent warning letter sent True"
    Then I choose option "Respondent police notified True"
    Then I choose option "Respondent bail conditions set True"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    And I should not see "Proceedings currently before court"
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "Statement" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I should be on a page showing "Confirm the following"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    And I should not see "Passported"

  @javascript @vcr
  Scenario: Receives benefits and completes the application
    Given I complete the passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I should be on a page showing 'receives benefits that qualify for legal aid'
    Then I click 'Continue'
    Then I should be on a page showing "Before you continue"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I choose "Yes, with a mortgage or loan"
    Then I click 'Save and continue'
    Then I should be on a page showing "How much is your client's home worth?"
    Then I fill "Property value" with "200000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I fill "Outstanding mortgage amount" with "100000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I choose "Yes, a partner or ex-partner"
    Then I click 'Save and continue'
    Then I should be on a page showing "What % share of their home does your client legally own?"
    Then I fill "Percentage home" with "50"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select "Current account"
    Then I fill "offline_current_accounts" with "-10"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I select "Money not in a bank account"
    Then I fill "Cash" with "10000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I select "Land"
    Then I fill "Land value" with "50000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Are there any legal restrictions that prevent your client from selling or borrowing against their assets?"
    Then I choose 'Yes'
    Then I fill 'Restrictions details' with 'Yes, there are restrictions. They include...'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click link "Back"
    Then I should be on a page showing "Are there any legal restrictions that prevent your client from selling or borrowing against their assets?"
    Then I click link "Back"
    Then I should be on a page showing "Which types of assets does your client have?"
    Then I click link "Back"
    Then I should be on a page showing "Which types of savings or investments does your client have?"
    Then I click link "Back"
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I click link "Back"
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I click link "Back"
    Then I should be on a page showing "What % share of their home does your client legally own?"
    Then I click link "Back"
    Then I should be on a page showing "Does your client own their home with anyone else?"
    Then I click link "Back"
    Then I should be on a page showing "What is the outstanding mortgage on your client's home?"
    Then I click link "Back"
    Then I should be on a page showing "How much is your client's home worth?"
    Then I click link "Back"
    Then I should be on a page showing "Does your client own the home that they live in?"
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I click 'Save and continue'
    Then I should be on a page showing 'We need to check if Test Walker should pay towards legal aid'
    Then I click 'Save and continue'
    Then I should be on a page showing "Provide details of the case"
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client tell you about the latest domestic abuse incident?'
    Then I enter the 'told' date of 2 days ago
    Then I enter the 'occurred' date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Opponent details"
    Then I choose option "Respondent understands terms of court order True"
    Then I choose option "Respondent warning letter sent True"
    Then I choose option "Respondent police notified True"
    Then I choose option "Respondent bail conditions set True"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I fill "Police notified details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    Then I should be on a page showing "Provide a statement of case"
    Then I fill "Statement" with "Statement of case"
    Then I upload a pdf file
    Then I click 'Upload'
    Then I reload the page
    Then I should be on a page showing "hello_world.pdf"
    Then I should be on a page showing "UPLOADED"
    Then I click 'Save and continue'
    Then I should be on a page showing "Is the chance of a successful outcome 50% or better?"
    Then I choose "No"
    Then I click 'Save and continue'
    Then I should be on a page showing "What is the chance of a successful outcome?"
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And I click Check Your Answers Change link for 'Statement of Case'
    Then I enter the statement 'This is some test data for the statement of case'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the answer for 'Statement of case' should be 'This is some test data for the statement of case'
    And I should be on a page showing "Confirm the following"
    Then I click 'Submit and continue'
    Then I should be on a page showing "Application complete"
    Then I click 'View completed application'
    Then I should be on a page showing "Application for civil legal aid certificate"
    Then I should be on a page showing "Passported"

  @javascript @vcr
  Scenario: View privacy policy
    Given I start the journey as far as the applicant page
    Then I click link "Privacy policy"
    Then I should be on a page showing "Why we need your data"
    Then I should be on a page showing "Your rights"
    Then I click link "Back"
    Then I should be on the Applicant page

  @javascript @vcr
  Scenario: View feedback form within provider journey
    Given I start the journey as far as the applicant page
    Then I click link "feedback"
    Then I click link "Back"
    Then I should be on the Applicant page

  @javascript @vcr
  Scenario: Enter feedback within provider journey
    Given I start the journey as far as the applicant page
    Then I click link "feedback"
    Then I should be on a page showing "Help us improve this service"
    Then I fill "improvement suggestion" with "Foo bar"
    Then I click "Send"
    Then I should be on a page showing "Thank you for your feedback"
    Then I click link "Back to your application"
    Then I should be on the Applicant page

  @javascript @vcr
  Scenario: Enter feedback within provider journey then click Back
    Given I start the journey as far as the applicant page
    Then I click link "feedback"
    Then I should be on a page showing "Help us improve this service"
    Then I fill "improvement suggestion" with "Foo bar"
    Then I click "Send"
    Then I should be on a page showing "Thank you for your feedback"
    Then I click link "Back"
    Then I should be on the Applicant page

  @javascript
  Scenario: Complete the vehicle part of the journey
    Given I start the journey as far as the start of the vehicle section
    Then I should be on a page showing "Does your client own a vehicle?"
    Then I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page showing "What is the estimated value of the vehicle?"
    Then I fill "Estimated value" with "4000"
    And I click "Save and continue"
    Then I should be on a page showing "Are there any payments left on the vehicle?"
    Then I choose option "Vehicle payments remain true"
    Then I fill "Payment remaining" with "2000"
    And I click "Save and continue"
    Then I should be on a page showing "Did your client buy the vehicle over 3 years ago?"
    Then I choose 'Yes'
    And I click "Save and continue"
    Then I should be on a page showing "Is the vehicle in regular use?"
    Then I choose option "Vehicle used regularly true"
    And I click "Save and continue"
    Then I should be on a page showing "Which bank accounts does your client have?"
    Then I select 'None of these'
    Then I click 'Save and continue'
    Then I should be on a page showing "Which types of savings or investments does your client have?"

  @javascript @vcr
  Scenario: Going to the search page
    Given I am logged in as a provider
    And An application has been created
    Then I visit the application service
    Then I click link "Start"
    Then I click link "Search applications"
    Then I should be on a page showing "Search applications"

  @javascript @vcr
  Scenario: Using the back button to change none_of_these checkboxes
    Given I am checking the applicant's means answers
    When I click Check Your Answers Change link for 'Savings and investments'
    Then I should be on the "offline_account" page showing "Which bank accounts does your client have?"
    When I select "None of these"
    And I click "Save and continue"
    Then I should be on the "savings_and_investment" page showing "Which types of savings or investments does your client have?"
    When I select "None of these"
    And I click "Save and continue"
    Then I should be on the 'means_summary' page showing 'Check your answers'
    When I click link "Back"
    Then I should be on the "savings_and_investment" page showing "Which types of savings or investments does your client have?"
    When I deselect "None of these"
    And I click "Save and continue"
    Then I should be on the "savings_and_investment" page showing "Select if your client has any of these savings or investments"
    When I select "None of these"
    And I click "Save and continue"
    Then I should be on the 'means_summary' page showing 'Check your answers'
    When I click Check Your Answers Change link for 'Other assets'
    Then I should be on the "other_assets" page showing "Which types of assets does your client have?"
    When I select "None of these"
    And I click "Save and continue"
    Then I should be on a page showing "Check your answers"
    When I click link "Back"
    Then I should be on the "other_assets" page showing "Which types of assets does your client have?"
    When I deselect "None of these"
    And I click "Save and continue"
    Then I should be on the "other_assets" page showing "Select if your client has any of these types of assets"
    Then I select "None of these"
    Then I click "Save and continue"
