Feature: Starting a case with no linking or copying

Background: I have started an application and not linked or copied it
  Given I am logged in as a provider
  And I have created and submitted an application with the application reference 'L-123-456'
  And the feature flag for linked_applications is enabled

  When I complete the non-passported journey as far as check your answers for linking
  And I have neither linked or copied an application

  When I visit the check_provider_answers page
  Then I should see 'Check your answers'
  And the following sections should exist:
    | tag | section |
    | h1  | Check your answers |
    | h3  | Client details |
    | h2  | Cases linked to this one |
    | h3  | Proceedings |
    | h3  | Non-molestation order |
  And the "linking items" list's questions, answers and action presence should match:
    | question | answer | action |
    | Link to another application? | No | true |
  And the following sections should not exist:
    | tag | section |
    | h3  | Copying |
    | h3  | Inherent jurisdiction high court injunction |

@javascript @vcr
Scenario: When I change it to be a linked case
  When I click Check Providers Answers Change link for "linking question"
  Then I should be on a page with title "Do you want to link this application with another one?"

  When I choose "Yes, I want to make a family link"
  And I click "Save and continue"
  Then I should be on a page with title "What is the LAA reference of the application you want to link to?"

  Then I search for laa reference 'L-123-456'
  And I click "Search"
  Then I should be on a page with title "Search result"
  And I should see "Is this the application you want to link to?"

  When I choose "Yes"
  And I click "Save and continue"
  Then I should be on a page with title "Do you want to copy the proceedings and merits from L-123-456 to this one?"
  And I should see "You've made a family link"

  When I choose "Yes, the information will be the same"
  And I click "Save and continue"

  Then I should be on a page showing 'Check your answers'
  And I should see "You have copied the proceedings and merits information from L-123-456 to this one."
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
