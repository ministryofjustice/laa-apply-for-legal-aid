@EjectCassetteAfterScenario
Feature: Checking answers for linked and copied cases

Background: I have started linking and copying a submitted application
  Given I have created and submitted an application with the application reference 'L-123-456'
  And the feature flag for linked_applications is enabled

  When I complete the non-passported journey as far as check your answers
  And I have linked and copied the 'L-123-456' application with a 'Family' link

  When I visit the check_provider_answers page
  Then I should see 'Check your answers'
  And the following sections should exist:
    | tag | section |
    | h1  | Check your answers |
    | h3  | Client details |
    | h2  | Cases linked to this one |
    | h3  | Copying |
    | h3  | Proceedings |
  And the "linking items" list's questions, answers and action presence should match:
    | question | answer | action |
    | Link to another application? | Yes | true |
    | Family link made to | Catelyn Stark, L-123-456, Inherent jurisdiction high court injunction | true |
  And the "copying items" list's questions and answers should match:
    | question | answer |
    | Copy from another application? | Yes |
    | Application copied | Catelyn Stark, L-123-456, Inherent jurisdiction high court injunction |
  And I should not see "Non-molestation order"

@javascript @vcr
Scenario: If I change the linked from Family to No
  When I click Check Providers Answers Change link for "linking question"
  Then I should be on a page with title "Do you want to link this application with another one?"

  When I choose "No"
  And I click "Save and continue"
  Then I should be on a page showing "What does your client want legal aid for?"
  And I should see 'Back'

  When I search for proceeding 'Non-molestation order'
  And proceeding suggestions has results
  And I choose a 'Non-molestation order' radio button
  And I click 'Save and continue'

  Then I should be on a page showing 'Do you want to add another proceeding?'
  When I choose 'No'
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
  When I choose 'Applicant, claimant or petitioner'
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
  When I choose 'Yes'
  And I enter the 'delegated functions on' date of 1 day ago
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order'
  And I should see 'Do you want to use the default level of service and scope for the emergency application?'
  When I choose 'Yes'
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order'
  And I should see 'Do you want to use the default level of service and scope for the substantive application?'
  When I choose 'Yes'
  And I click 'Save and continue'

  Then I should be on a page showing "What you're applying for"
  And I should be on a page showing "default substantive cost limit"
  And I should be on a page showing "Do you want to request a higher emergency cost limit?"

  When I choose 'No'
  And I click 'Save and continue'
  Then I should be on a page showing 'Check your answers'
  And I should see "Non-molestation order"

@javascript @vcr
Scenario: If I change the copied from Yes to No
  When I click Check Your Answers summary card Change link for "copying"
  Then I should be on a page with title "Do you want to copy the proceedings and merits from L-123-456 to this one?"

  When I choose "No, I need to make changes"
  And I click "Save and continue"
  Then I should be on a page showing "What does your client want legal aid for?"


  When I search for proceeding 'Non-molestation order'
  And proceeding suggestions has results
  And I choose a 'Non-molestation order' radio button
  And I click 'Save and continue'

  Then I should be on a page showing 'Do you want to add another proceeding?'
  When I choose 'No'
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
  When I choose 'Applicant, claimant or petitioner'
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
  When I choose 'Yes'
  And I enter the 'delegated functions on' date of 1 day ago
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order'
  And I should see 'Do you want to use the default level of service and scope for the emergency application?'
  When I choose 'Yes'
  And I click 'Save and continue'
  Then I should see 'Proceeding 1\nNon-molestation order'
  And I should see 'Do you want to use the default level of service and scope for the substantive application?'
  When I choose 'Yes'
  And I click 'Save and continue'

  Then I should be on a page showing "What you're applying for"
  And I should be on a page showing "default substantive cost limit"

  And I click 'Save and continue'
  Then I should be on a page showing 'Check your answers'
  And I should see "Non-molestation order"
