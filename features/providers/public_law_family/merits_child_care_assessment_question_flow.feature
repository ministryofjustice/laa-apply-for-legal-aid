Feature: Public law family merits appeal question flow

  @javascript
  Scenario: When application is for public law family matter requiring child care assessment
    Given csrf is enabled
    When I complete the journey as far as merits task list for a PLF proceeding with child care assessment question
    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'

    Then I should see "About the application"
    And I should see 'Opponents Not started'
    And I should see 'Statement of case Not started'
    And I should see 'Children involved in this application Not started'

    Then I should see "About the Special guardianship order"
    And I should see 'Children involved in this proceeding Cannot start yet'
    And I should see 'Chances of success Not started'
    And I should see 'Assessment of your client Not started'

    ############################
    # opponent
    ############################
    When I click link 'Opponent'
    Then I should be on a page with title "Is the opponent an individual or an organisation?"
    And I choose a 'An individual' radio button
    When I click 'Save and continue'
    Then I should be on a page with title "Opponent"
    When I fill "First Name" with "John"
    Then I fill "Last Name" with "Doe"

    When I click 'Save and continue'
    Then I should be on a page with title "You have added 1 opponent"
    And I should be on a page showing "Do you need to add another opponent?"

    When I choose "No"
    And I click 'Save and continue'

    ############################
    # statement of case
    ############################
    Then I should be on a page showing "Statement of case"
    And I select "Type a statement"
    When I fill "Application merits task statement of case statement field" with "Statement of case"
    And I click 'Save and continue'

    ##################################
    # Children involved in application
    #################################
    Then I should be on the 'involved_children/new' page showing 'Enter details of the children involved in this application'
    When I fill "Full Name" with "John Doe Jr"
    And I enter a 'date_of_birth' for a 14 year old

    When I click 'Save and continue'
    Then I should be on the 'has_other_involved_children' page showing 'You have added 1 child'
    When I choose 'No'
    And I click 'Save and continue'

    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'
    And I should see 'Opponents Completed'
    And I should see 'Statement of case Completed'
    And I should see 'Children involved in this application Completed'

    Then I should see "About the Special guardianship order"
    And I should see 'Children involved in this proceeding Not started'
    And I should see 'Chances of success Not started'
    And I should see 'Assessment of your client Not started'

    #################################
    # Children involved in proceeding
    #################################
    When I click link 'Children involved in this proceeding'
    Then I should be on the 'linked_children' page showing 'Which children are covered under this proceeding?'

    When I select 'John Doe Jr'
    And I click 'Save and continue'
    Then I should be on the 'chances_of_success' page showing 'Is the chance of a successful outcome 45% or better?'

    #################################
    # Child care assessment of client
    #################################
    When I choose "Yes"
    And I click 'Save and continue'

    Then I should be on the 'assessment_of_client' page showing "Has the local authority assessed your client's ability to care for the children involved?"
    And I should see "For example, if your client is the grandparent, the local authority may check if they could be a suitable carer"
    And I should see "You'll need to upload supporting evidence later"

    # Test the error
    When I click "Save and continue"
    Then I should see govuk error summary "Select yes if the local authority has assessed your client's ability to care for the children involved"

    #################################
    # Child care assessment of client
    # assessment yes, assessment result positive
    #################################
    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on the 'assessment_result' page showing "Was the assessment positive or negative?"

    # Test the error
    When I click "Save and continue"
    Then I should see govuk error summary "Select if the assessment was positive or negative"
    Then I should not see "Enter how the negative assessment will be challenged"

    When I choose "Positive"
    And I click "Save and continue"

    Then I should be on the 'merits_task_list' page showing 'Provide details of the case'
    And I should see 'Opponents Completed'
    And I should see 'Statement of case Completed'
    And I should see 'Children involved in this application Completed'

    Then I should see "About the Special guardianship order"
    And I should see 'Children involved in this proceeding Completed'
    And I should see 'Chances of success Completed'
    And I should see 'Assessment of your client Completed'

    When I click 'Save and continue'
    Then I should be on a page with title 'Upload supporting evidence'

    # Test the error
    When I click 'Save and continue'
    Then I should see govuk error summary "Upload the local authority assessment"

    When I upload an evidence file named 'hello_world.pdf'
    Then I should see 'hello_world.pdf'
    And I select a category of "Assessment" for the file "hello_world.pdf"

    #################################
    # Child care assessment of client
    # assessment yes, assessment result negative
    #################################
    When I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the govuk-summary-card titled "Assessment of your client" should contain:
      | question | answer |
      | Client's ability to care was assessed by the local authority? | Yes |
      | Assessment result | Positive |

    And I should not see "How the result will be challenged"

    When I click the govuk-summary-card titled "Assessment of your client" Change link
    Then I should be on the 'assessment_of_client' page showing "Has the local authority assessed your client's ability to care for the children involved?"

    When I click 'Save and continue'
    Then I should be on the 'assessment_result' page showing "Was the assessment positive or negative?"

    When I choose "Negative"
    Then I should see "How will the negative assessment be challenged?"

    # Test the error
    When I click "Save and continue"
    Then I should see govuk error summary "Enter how the negative assessment will be challenged"
    And I should not see "Select if the assessment was positive or negative"

    When I fill "proceeding-merits-task-child-care-assessment-details-field-error" with "I will challenge the negative assessment by..."
    And I click "Save and continue"
    Then I should be on a page with title 'Upload supporting evidence'
    Then I should see 'hello_world.pdf'

    When I click "Save and continue"
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the govuk-summary-card titled "Assessment of your client" should contain:
      | question | answer |
      | Client's ability to care was assessed by the local authority? | Yes |
      | Assessment result | Negative |
      | How the result will be challenged | I will challenge the negative assessment by... |

    #################################
    # Child care assessment of client
    # assessment no
    #################################
    When I click the govuk-summary-card titled "Assessment of your client" Change link
    Then I should be on the 'assessment_of_client' page showing "Has the local authority assessed your client's ability to care for the children involved?"

    When I choose "No"
    When I click 'Save and continue'
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the govuk-summary-card titled "Assessment of your client" should contain:
      | question | answer |
      | Client's ability to care was assessed by the local authority? | No |

    And I should not see "Assessment result"
    And I should not see "How the result will be challenged"
