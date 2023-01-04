Feature: Checking client details answers backwards and forwards

  @javascript
  Scenario: I am able to see the client details
    Given I complete the passported journey as far as check your answers for client details

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Proceedings |
      | h2  | Inherent jurisdiction high court injunction proceeding details |
      | h2  | What happens next |

    And the "Client details" check your answers section should contain:
      | question | answer |
      | First name | Test |
      | Last name | Walker |
      | Date of birth | 10 January 1980 |
      | Correspondence address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |
      | National Insurance number | JA293483A |

  @javascript
  Scenario: I am able to return and amend the client's name
    Given I complete the passported journey as far as check your answers for client details
    And the "Client details" check your answers section should contain:
      | question | answer |
      | First name | Test |
      | Last name | Walker |

    When I click Check Your Answers Change link for "First name"
    Then I should be on a page with title "Enter your client's details"

    When I enter name 'Fred', 'Bloggs'
    And I click 'Save and continue'
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I click 'Save and continue'
    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question | answer |
      | First name | Fred |
      | Last name | Bloggs |

  @javascript @vcr
  Scenario: I am able to return and amend the client's address
    Given I complete the passported journey as far as check your answers for client details
    And I should see "Transport For London"

    When I click Check Your Answers Change link for "address"
    Then I should be on a page with title "Enter your client's correspondence address"

    When I click 'Find address'
    And I select an address 'British Transport Police, 98 Petty France, London, SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"
    And I should see "British Transport Police"

  @javascript
  Scenario: I am able to return and remove the client's national insurance number
    Given I complete the passported journey as far as check your answers for client details
    And the "Client details" check your answers section should contain:
      | question | answer |
      | National Insurance number | JA293483A |

    And the following sections should exist:
      | tag | section |
      | h2  | What happens next |

    And I should see "to check their benefit status"

    When I click Check Your Answers Change link for "National Insurance number"
    Then I should be on a page with title "Does the client have a National Insurance number?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question | answer |
      | National Insurance number | Not provided |

    And I should not see "What happens next"
    And I should not see "to check their benefit status"

