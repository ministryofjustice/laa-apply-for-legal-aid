Feature: Check merits answers
  @javascript @vcr
  Scenario: Checking merits answers for an application with multiple procedings
    Given I complete the journey as far as check merits answers with multiple proceedings
    Then I should be on a page showing "Fake gateway evidence file"
    Then I should be on a page showing "Fake file name 1 (15.7 KB)"
    Then I should be on a page showing "Statement of case text entered here"
    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Case details |
      | h3  | Opponents |
      | h3  | Mental capacity |
      | h3  | Domestic abuse summary |
      | h3  | Statement of case |
      | h3  | Children involved in this application |
      | h3  | Section 8 and LASPO |
      | h3  | Why the matter is opposed |
      | h3  | Allegation |
      | h3  | Offer of undertakings |
      | h2  | Inherent jurisdiction high court injunction |
      | h2  | Non-molestation order |
      | h2  | Child arrangements order (residence) |
      | h3  | Chances of success |
      | h3  | Children covered |
      | h3  | Files to support the application |

    And the following sections should not exist:
      | tag | section |
      | h2  | Supervision order |

  @javascript
  Scenario: On a PLF application where a proceeding has second appeal merits task list item
    Given I complete the journey as far as check merits answers with a PLF proceeding with second appeal question
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h3  | Opponents |
      | h3  | Statement of case |
      | h3  | Children involved in this application |
      | h2  | Second appeal |

    And the "Second appeal" check your answers section should contain:
      | question | answer |
      | Second appeal? | No |
      | Original case heard by | Recorder Circuit Judge (HHJ) |
      | Appeal will be heard in | Any other court |

    ###################################
    # ECCT question 1 and 3 only needed
    ###################################
    When I click Check Your Answers Change link for 'second_appeal_heading'
    Then I should be on a page with title "Is this a second appeal?"
    And I should be on a page showing "Is this a second appeal?"
    And I should see "This question will help us decide if a specialist caseworker should review your application."

    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on the 'second_appeal_court_type' page showing 'Which court will the second appeal be heard in?'

    When I choose "Supreme court"
    And I click "Save and continue"

    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the "Second appeal" check your answers section should contain:
      | question | answer |
      | Second appeal? | Yes |
      | Appeal will be heard in | Supreme court |

    And the "Second appeal" check your answers section should not contain:
      | question |
      | Original case heard by |

    ###################################
    # ECCT question 1 and 2 only needed
    ###################################
    When I click Check Your Answers Change link for 'second_appeal_heading'
    Then I should be on a page with title "Is this a second appeal?"

    When I choose "No"
    And I click "Save and continue"

    Then I should be on a page with title "What level of judge heard the original case?"
    And I should be on a page showing "What level of judge heard the original case?"
    And I should see "This question will help us decide if a specialist caseworker should review your application."

    When I choose "Deputy District Judge (DDJ)"
    And I click "Save and continue"
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the "Second appeal" check your answers section should contain:
      | question | answer |
      | Second appeal? | No |
      | Original case heard by | Deputy District Judge (DDJ) |

    And the "Second appeal" check your answers section should not contain:
      | question |
      | Appeal will be heard in |

    ###################################
    # ECCT question 1, 2 and 4 needed
    ###################################
    When I click Check Your Answers Change link for 'second_appeal_heading'
    Then I should be on a page with title "Is this a second appeal?"

    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "What level of judge heard the original case?"

    When I choose "High Court Judge (J)"
    And I click "Save and continue"
    Then I should be on the 'appeal_court_type' page showing 'Which court will the appeal be heard in?'

    When I choose "Any other court"
    And I click "Save and continue"
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the "Second appeal" check your answers section should contain:
      | question | answer |
      | Second appeal? | No |
      | Original case heard by | High Court Judge (J) |
      | Appeal will be heard in | Any other court |

  @javascript
  Scenario: On a PLF application where a proceeding has child care assessment merits task list item
    Given I complete the journey as far as check merits answers with a PLF proceeding child care assessment question
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h3  | Opponents |
      | h3  | Statement of case |
      | h3  | Children involved in this application |
      | h3  | Chances of success |
      | h3  | Assessment of your client |

    And the govuk-summary-card titled "Assessment of your client" should contain:
      | question | answer |
      | Client's ability to care was assessed by the local authority? | No |

    When I click the govuk-summary-card titled "Assessment of your client" Change link
    Then I should be on a page with title "Special guardianship order - Has the local authority assessed your client's ability to care for the children involved?"

    # TODO: AP-5533: should goto assessment result page
    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on the 'check_merits_answers' page showing 'Check your answers'
    And the govuk-summary-card titled "Assessment of your client" should contain:
      | question | answer |
      | Client's ability to care was assessed by the local authority? | Yes |

  @javascript
  Scenario: On an SCA application where a proceeding has no questions on the merits task list
    Given I complete the journey as far as check merits answers with SCA proceedings with merits tasks
    And the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Case details |
      | h3  | Opponents |
      | h2  | Child assessment order |
      | h2  | Supervision order |
      | h3  | Who your client is in the proceeding |
