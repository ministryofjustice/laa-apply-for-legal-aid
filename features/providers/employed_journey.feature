Feature: Employed journey

@javascript
Scenario: Completing the means journey for an employed applicant with HMRC data
  Given I start the means review journey with employment income for a single job from HMRC
  Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
  When I click 'Continue'
  Then I should be on the 'employment_income' page showing 'The information on this page has been provided by HMRC.'
  When I click 'Save and continue'
  Then I should be on the 'employment_income' page showing "Select yes if you need to tell us anything else about your client's employment"
  When I choose 'Yes'
  And I click 'Save and continue'
  Then I should be on the 'employment_income' page showing "Enter details about your client’s employment"
  When I fill "legal aid application extra employment information details error" with "some extra details about employment"
  And I click 'Save and continue'
  Then I should be on the 'identify_types_of_income' page showing "Which payments does your client receive?"
  Then I select "My client receives none of these payments"
  And I click 'Save and continue'
  Then I should be on a page showing "Does your client receive student finance?"

  When I choose "No"
  And I click 'Save and continue'
  Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"
  Then I select "My client makes none of these payments"
  And I click 'Save and continue'
  Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"

  When I choose "No"
  And I click 'Save and continue'
  Then I should be on the 'check_answers_incomes' page showing 'Check your answers'
  And the answer for 'extra_employment_information' should be 'Yes'
  And the answer for 'extra_employment_information_details' should be 'some extra details about employment'


@javascript
Scenario: Completing the means journey for an employed applicant with no HMRC data
  Given I start the means review journey with no employment income from HMRC
  Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
  When I click 'Continue'
  Then I should be on the 'full_employment_details' page showing "HMRC has no record of your client's employment in the last 3 months"
  When I click 'Save and continue'
  Then I should be on the 'full_employment_details' page showing "Enter your client's employment details"
  Then I fill "legal aid application full employment details error" with "all the details about employment"
  And I click 'Save and continue'

  Then I should be on the 'identify_types_of_income' page showing "Which payments does your client receive?"
  Then I select "My client receives none of these payments"
  And I click 'Save and continue'
  Then I should be on a page showing "Does your client receive student finance?"

  When I choose "No"
  And I click 'Save and continue'
  Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"
  Then I select "My client makes none of these payments"
  And I click 'Save and continue'
  Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"

  When I choose "No"
  And I click 'Save and continue'
  Then I should be on the 'check_answers_incomes' page showing 'Check your answers'
  And the answer for 'full_employment_details' should be 'all the details about employment'

@javascript
Scenario: Completing the means journey for an employed applicant with multiple jobs
  Given I start the means review journey with employment income for multiple jobs from HMRC
  Then I should be on the 'client_completed_means' page showing 'Your client has shared their financial information'
  When I click 'Continue'
  Then I should be on the 'full_employment_details' page showing "HMRC says your client had more than one job in the last 3 months."
  When I click 'Save and continue'
  Then I should be on the 'full_employment_details' page showing "Enter your client's employment details"
  Then I fill "legal aid application full employment details error" with "all the details about employment"
  And I click 'Save and continue'

  Then I should be on the 'identify_types_of_income' page showing "Which payments does your client receive?"
  Then I select "My client receives none of these payments"
  And I click 'Save and continue'
  Then I should be on a page showing "Does your client receive student finance?"

  When I choose "No"
  And I click 'Save and continue'
  Then I should be on the 'identify_types_of_outgoing' page showing "Which payments does your client make?"
  Then I select "My client makes none of these payments"

  And I click 'Save and continue'
  Then I should be on the 'has_dependants' page showing "Does your client have any dependants?"

  When I choose "No"
  And I click 'Save and continue'
  Then I should be on the 'check_answers_incomes' page showing 'Check your answers'
  And the answer for 'full_employment_details' should be 'all the details about employment'
