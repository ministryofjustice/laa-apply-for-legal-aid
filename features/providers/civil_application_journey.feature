Feature: Civil application journeys
  @javascript
  Scenario: I am able to return to my legal aid applications
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click "Start now"
    And I click link "Apply for Legal Aid"
    Then I am on the legal aid applications

  @javascript @vcr
  Scenario: No results returned is seen on screen when invalid proceeding search entered
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click "Start now"
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click 'Save and continue'
    When the search for "cakes" is not successful
    Then the result list on page returns a "No results found." message

  @javascript @vcr
  Scenario: I am able to clear proceeding on the proceeding page
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click "Start now"
    Then I should be on the Applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
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
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
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
    Then I should be on a page showing "What you're covered for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I am able to select and delete proceeding types
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click 'Save and continue'
    And I search for proceeding 'app'
    Then proceeding suggestions has results
    When I select proceeding type 2
    Then I expect to see 1 proceeding types selected
    When I click the first 'Remove' in selected proceeding types
    Then I expect to see 0 proceeding types selected
    And I search for proceeding 'child'
    When I select proceeding type 4
    Then I expect to see 1 proceeding types selected
    When I click 'Save and continue'
    Then I should be on a page showing "What you're covered for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript
  Scenario: I complete each step up to the applicant page
    # testing shared steps: Given I start the journey as far as the applicant page
    Given I am logged in as a provider
    Given I visit the application service
    And I click link "Start"
    And I click "Start now"
    Then I should be on the Applicant page

  @javascript @vcr
  Scenario: Completes the application using address lookup
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click 'Save and continue'
    Then I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing "What you're covered for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I am on the benefit check results page
    When I click 'Continue'
    Then I am on the client use online banking page
    Then I choose "Yes"
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
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'SW1H 9AJ'
    Then I click find address
    Then I enter address line one '102 Petty France'
    Then I enter city 'London'
    Then I enter postcode 'SW1H 9AJ'
    Then I click 'Save and continue'
    Then I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing "What you're covered for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I am on the benefit check results page
    When I click 'Continue'
    Then I am on the client use online banking page
    Then I choose "Yes"
    Then I click 'Save and continue'
    Then I am on the About the Financial Assessment page
    Then I click 'Send client link'
    Then I am on the application confirmation page

  @javascript @vcr
  Scenario: I can see that the applicant receives benefits
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Walker'
    Then I enter the date of birth '10-01-1980'
    Then I enter national insurance number 'JA293483A'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click 'Save and continue'
    Then I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing "What you're covered for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I am on the benefit check results page
    Then I see a notice saying that the citizen receives benefits

  @javascript @vcr
  Scenario: I can see that the applicant does not receive benefits
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Paul'
    Then I enter the date of birth '10-12-1961'
    Then I enter national insurance number 'JA293483B'
    Then I fill 'email' with 'test@test.com'
    Then I click 'Save and continue'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click 'Save and continue'
    Then I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing "What you're covered for"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I am on the benefit check results page
    Then I see a notice saying that the citizen does not receive benefits

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
    And I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I select a proceeding type and continue
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to return to the check your answers page without changing proceeding type
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Proceeding Type'
    And I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I click link "Back"
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change email from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Email'
    Then I fill 'email' with 'foo@example.com'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    And the answer for 'Email' should be 'foo@example.com'

  @javascript @vcr
  Scenario: I want to return to the check your answers page without changing email
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Email'
    Then I click link "Back"
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change address from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Address'
    Then I am on the postcode entry page
    Then I enter a postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
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
    Then I should be on a page showing "Apply for Legal Aid"

  @javascript
  Scenario: I want to return to applicant from Contact page
    Given I start the journey as far as the applicant page
    Then I click link "Contact"
    Then I should be on a page showing "Contact us"
    Then I click link "Back"
    Then I should be on the Applicant page

  @javascript @vcr
  Scenario: Completes the merits application for applicant that does not receive benefits
    Given I start the merits application
    Then I should be on a page showing 'Your client has completed their financial assessment'
    Then I click 'Continue'
    Then I should be on a page showing "Your client's income"
    Then I click 'Save and continue'
    Then I should be on a page showing "Your client’s regular payments"
    Then I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'
    Then I click 'Save and continue'
    Then I should be on a page showing 'Provide details of the case'
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client tell you about the latest domestic abuse incident?'
    Then I enter the told on date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing 'Enter details of the latest incident'
    Then I enter the occurred on date of 2 days ago
    Then I fill "Details" with "It happened"
    Then I click 'Save and continue'
    Then I should be on a page showing "Respondent details"
    Then I choose option "Respondent understands terms of court order True"
    Then I choose option "Respondent warning letter sent True"
    Then I choose option "Respondent police notified True"
    Then I choose option "Respondent bail conditions set True"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    And I should not see "Proceedings currently before court"
    Then I should be on a page showing "Statement of case"
    Then I fill "Statement" with "Statement of case"
    Then I click 'Save and continue'
    Then I should be on a page showing "What are the estimated legal costs of doing the work?"
    Then I fill "Estimated legal cost" with "1000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What are the prospects of success?"
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the answer for 'Estimated legal costs' should be "£1,000.00"
    Then I click "Save and continue"
    Then I should be on a page showing "Declaration"
    Then I click 'Submit and continue'
    Then I should be on a page showing "End of provider-answered merits assessment questions for passported clients"


  @javascript @vcr
  Scenario: Receives benefits and completes the application
    Given I complete the passported journey as far as check your answers
    Then I click 'Save and continue'
    Then I am on the benefit check results page
    Then I see a notice saying that the citizen receives benefits
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
    Then I should be on a page showing "Does your client have any savings and investments?"
    Then I select "Cash savings"
    Then I fill "Cash" with "10000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Does your client have any of the following?"
    Then I select "Land"
    Then I fill "Land value" with "50000"
    Then I click 'Save and continue'
    Then I should be on a page showing "Do any of the following restrictions apply to your client's property or other assets?"
    Then I select "Bankruptcy"
    Then I select "Held overseas"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    Then I click link "Back"
    Then I should be on a page showing "Do any of the following restrictions apply to your client's property or other assets?"
    Then I click link "Back"
    Then I should be on a page showing "Does your client have any of the following?"
    Then I click link "Back"
    Then I should be on a page showing "Does your client have any savings and investments?"
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
    Then I should be on a page showing "Provide details of the case"
    Then I click 'Continue'
    Then I should be on a page showing 'When did your client tell you about the latest domestic abuse incident?'
    Then I enter the told on date of 2 days ago
    Then I click 'Save and continue'
    Then I should be on a page showing "Enter details of the latest incident"
    Then I enter the occurred on date of 2 days ago
    Then I fill "Details" with "It happened"
    Then I click 'Save and continue'
    Then I should be on a page showing "Respondent details"
    Then I choose option "Respondent understands terms of court order True"
    Then I choose option "Respondent warning letter sent True"
    Then I choose option "Respondent police notified True"
    Then I choose option "Respondent bail conditions set True"
    Then I fill "Bail conditions set details" with "Foo bar"
    Then I click 'Save and continue'
    And I should not see "Client received legal help"
    Then I should be on a page showing "Statement of case"
    Then I fill "Statement" with "Statement of case"
    Then I upload a pdf file
    Then I reload the page
    Then I should be on a page showing "hello_world.pdf"
    Then I should be on a page showing "UPLOADED"
    Then I click 'Save and continue'
    Then I should be on a page showing "What are the estimated legal costs of doing the work?"
    Then I fill "Estimated legal cost" with "1000"
    Then I click 'Save and continue'
    Then I should be on a page showing "What are the prospects of success?"
    Then I choose "Borderline"
    Then I fill "Success prospect details" with "Prospects of success"
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And I click Check Your Answers Change link for 'Statement of Case'
    Then I enter the statement 'This is some test data for the statement of case'
    Then I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the answer for 'Statement of case' should be 'This is some test data for the statement of case'
    Then I click Check Your Answers Change link for 'Estimated legal costs'
    Then I should be on a page showing "What are the estimated legal costs of doing the work?"
    Then I fill "Estimated legal cost" with "2345"
    And I click 'Save and continue'
    Then I should be on a page showing "Check your answers"
    And the answer for 'Estimated legal costs' should be "£2,345.00"
    Then I click "Save and continue"
    Then I should be on a page showing "Declaration"
    Then I click 'Submit and continue'
    Then I should be on a page showing "End of provider-answered merits assessment questions for passported clients"

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
