@EjectCassetteAfterScenario
Feature: Checking answers for linked cases without copying

Background: I have started linking to a submitted application
  Given I have created and submitted an application with the application reference 'L-123-456'
  And the feature flag for linked_applications is enabled

  When I complete the non-passported journey as far as check your answers
  And I have linked not copied the 'L-123-456' application with a 'Family' link

  When I visit the check_provider_answers page
  Then I should see 'Check your answers'
  And the following sections should exist:
    | tag | section |
    | h1  | Check your answers |
    | h3  | Client details |
    | h2  | Cases linked to this one |
    | h3  | Proceedings |
    | h3  | Non-molestation order |
  And the following sections should not exist:
    | tag | section |
    | h3  | Inherent jurisdiction high court injunction |
  And the "linking items" list's questions, answers and action presence should match:
    | question | answer | action |
    | Link to another application? | Yes | true |
    | Family link made to | Catelyn Stark, L-123-456, Inherent jurisdiction high court injunction | true |
  And the "copying items" list's questions and answers should match:
    | question | answer |
    | Copy from another application? | No |

@javascript @vcr
Scenario: If I change the copy case from No to Yes
  When I click Check Your Answers summary card Change link for "copying"
  Then I should be on a page with title "Do you want to copy the proceedings and merits from L-123-456 to this one?"

  When I choose "Yes, the information will be the same"
  And I click "Save and continue"

  Then I should be on a page showing 'Check your answers'
  And the following sections should exist:
    | tag | section |
    | h1  | Check your answers |
    | h3  | Client details |
    | h2  | Cases linked to this one |
    | h3  | Proceedings |
    | h3  | Inherent jurisdiction high court injunction |
  And the following sections should not exist:
    | tag | section |
    | h3  | Non-molestation order |
  And the "copying items" list's questions and answers should match:
    | question | answer |
    | Copy from another application? | Yes |
    | Application copied | Catelyn Stark, L-123-456, Inherent jurisdiction high court injunction |
