Feature: Civil application journeys
  @javascript
  Scenario: I am able to return to my legal aid applications
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    And I search for proceeding 'app'
    Then proceeding suggestions has results
    When I click clear search
    Then the results section is empty
    Then proceeding search field is empty
    And I click link "Apply for Legal Aid"
    Then I am on the legal aid applications

  @javascript
  Scenario: No results returned is seen on screen when invalid search entered
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    When the search for "cakes" is not successful
    Then the result list on page returns a "No results found." message

  @javascript
  Scenario: I am able to clear proceeding on the proceeding page
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    And I search for proceeding 'app'
    Then proceeding suggestions has results
    When I click clear search
    Then the results section is empty
    Then proceeding search field is empty

  @javascript
  Scenario: I complete each step up to the applicant page
    # testing shared steps: Given I start the journey as far as the applicant page
    Given I visit the application service
    And I click link "Start"
    And I click link "Start now"
    And I search for proceeding 'Application for a care order'
    Then proceeding suggestions has results
    Then I select and continue
    Then I should be on the Applicant page

  @javascript @vcr
  Scenario: Completes the application using address lookup
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I enter a valid email address 'test@test.com'
    Then I click continue
    Then I am on the postcode entry page
    Then I enter a valid postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click continue
    Then I am on the benefit check results page
    Then I click continue
    When I click "Submit"
    Then I am on the application confirmation page

  @localhost_request @javascript @vcr
  Scenario: Completes the application using manual address
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'User'
    Then I enter the date of birth '03-04-1999'
    Then I enter national insurance number 'CB987654A'
    Then I enter a valid email address 'test@test.com'
    Then I click continue
    Then I am on the postcode entry page
    Then I enter a valid postcode 'SW1H 9AJ'
    Then I click find address
    Then I enter address line one '102 Petty France'
    Then I enter city 'London'
    Then I enter postcode 'SW1H 9AJ'
    Then I click continue
    Then I am on the benefit check results page
    Then I click continue
    When I click "Submit"
    Then I am on the application confirmation page

  @javascript @vcr
  Scenario: I can see that the applicant receives benefits
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Walker'
    Then I enter the date of birth '10-01-1980'
    Then I enter national insurance number 'JA293483A'
    Then I enter a valid email address 'test@test.com'
    Then I click continue
    Then I am on the postcode entry page
    Then I enter a valid postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click continue
    Then I am on the benefit check results page
    Then I see a notice saying that the citizen receives benefits

  @javascript @vcr
  Scenario: I can see that the applicant does not receive benefits
    Given I start the journey as far as the applicant page
    Then I enter name 'Test', 'Paul'
    Then I enter the date of birth '10-12-1961'
    Then I enter national insurance number 'JA293483B'
    Then I enter a valid email address 'test@test.com'
    Then I click continue
    Then I am on the postcode entry page
    Then I enter a valid postcode 'DA74NG'
    Then I click find address
    Then I select an address '3, LONSDALE ROAD, BEXLEYHEATH, DA7 4NG'
    Then I click continue
    Then I am on the benefit check results page
    Then I see a notice saying that the citizen does not receive benefits

  @javascript @vcr
  Scenario: I want to make changes from the check your answers page
    Given I complete the journey as far as check your answers
