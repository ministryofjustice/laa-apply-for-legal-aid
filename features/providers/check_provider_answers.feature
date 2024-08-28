Feature: Checking client details answers backwards and forwards
  @javascript
  Scenario: Send client's mail to their home address
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
      | Has your client ever changed their last name? | No |
      | Date of birth | 10 January 1980 |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |
      | National Insurance number | JA293483A |
      | Does your client have a partner | No |
  
  @javascript
  Scenario: Send client's mail to another residential address
    Given I complete the passported journey as far as check your answers and send correspondence to another uk residential address
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
      | Has your client ever changed their last name? | No |
      | Date of birth | 10 January 1980 |
      | Correspondence address | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Care of recipient | Brian Surname |
      | Client has a home address? | Yes |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |
      | National Insurance number | JA293483A |
      | Does your client have a partner | No |

  @javascript
  Scenario: I am able to return and amend the client's name
    Given I complete the passported journey as far as check your answers for client details
    And the "Client details" check your answers section should contain:
      | question | answer |
      | First name | Test |
      | Last name | Walker |
      | Has your client ever changed their last name? | No |

    And I should not see "What was your client's last name at birth?"

    When I click Check Your Answers Change link for "First name"
    Then I should be on a page with title "Enter your client's details"

    When I enter name 'Fred', 'Bloggs'
    When I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

    And the "Client details" check your answers section should contain:
      | question | answer |
      | First name | Fred |
      | Last name | Bloggs |
      | Has your client ever changed their last name? | No |

  @javascript
  Scenario: I am able to return and amend the client's last name at birth
    Given I complete the passported journey as far as check your answers for client details
    And the "Client details" check your answers section should contain:
      | question | answer |
      | First name | Test |
      | Last name | Walker |
      | Has your client ever changed their last name? | No |

    And I should not see "What was your client's last name at birth?"

    When I click Check Your Answers Change link for "Changed last name"
    Then I should be on a page with title "Enter your client's details"

    And I choose 'Yes'
    Then I enter last name at birth 'Bloggs'

    When I click 'Save and continue'
    Then I should be on a page with title "Check your answers"

    And the "Client details" check your answers section should contain:
      | question | answer |
      | First name | Test |
      | Last name | Walker |
      | Has your client ever changed their last name? | Yes |
      | What was your client's last name at birth? | Bloggs |

  @javascript @vcr
  Scenario: I am able to return and amend the client's home address
    Given I complete the passported journey as far as check your answers for client details
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |
    When I click Check Your Answers Change link for "home address"
    Then I should be on a page with title "Find your client's home address"
    Then I enter a postcode 'SW1H 9EA'
    When I click 'Find address'
    And I choose an address 'British Transport Police, 98 Petty France, London, SW1H 9EA'
    And I click 'Use this address'
    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question     | answer                                                      |
      | Home address | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |

  @javascript @vcr
  Scenario: I am able to return and amend the client's correspondence address
    Given I complete the passported journey as far as check your answers and send correspondence to another uk residential address
    And the "Client details" check your answers section should contain:
      | question               | answer                                                      |
      | Correspondence address | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address           | Transport For London\n98 Petty France\nLondon\nSW1H 9EA     |
    When I click Check Your Answers Change link for "address"
    Then I should be on a page with title "Find your client's correspondence address"
    Then I enter a postcode 'SW1H 9EA'
    When I click 'Find address'
    And I choose an address 'C P S, 102 Petty France, London, SW1H 9EA'
    And I click 'Use this address'
    Then I should be on a page with title "Do you want to add a 'care of' recipient for your client's mail?"
    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Correspondence address | C P S\n102 Petty France\nLondon\nSW1H 9EA |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |

  @javascript @vcr
  Scenario: I am able to return and amend the client's correspondence address which is an office
    Given I complete the passported journey as far as check your answers and send correspondence to a uk office address
    And the "Client details" check your answers section should contain:
      | question               | answer                                                      |
      | Correspondence address | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address           | Transport For London\n98 Petty France\nLondon\nSW1H 9EA     |
    When I click Check Your Answers Change link for "address"
    Then I should be on a page with title "Enter your client's correspondence address"
    Then I enter address line one 'Fake Company'
    Then I enter address line two 'Fake Road'
    Then I enter city 'Fake City'
    Then I enter postcode 'XX1 1XX'
    Then I click 'Save and continue'

    Then I should be on a page with title "Do you want to add a 'care of' recipient for your client's mail?"
    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Correspondence address | Fake Company\nFake Road\nFake City\nXX1 1XX |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |

  @javascript @vcr
  Scenario: I am able to return and amend the client's overseas home address
    Given the feature flag for home_address is enabled
    And I complete the passported journey as far as check your answers with an overseas address
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Correspondence address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address | Alemannenstrasse 1\nStuttgart D-12345 |
    When I click Check Your Answers Change link for "home address"
    Then I should be on a page with title "Find your client's home address"
    And I click link "Enter a non-UK address"
    And I enter a country "France"
    And I choose "France"
    Then I complete overseas home address 'address line one' with 'Grande Rue 2'
    Then I complete overseas home address 'address line two' with 'Marseille F-54321'
    Then I click 'Save and continue'
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Correspondence address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address | Grande Rue 2\nMarseille F-54321\nFrance |

  @javascript @vcr
  Scenario: I am able to change from "Another UK residential address" to "My client's UK home address"
    Given I complete the passported journey as far as check your answers and send correspondence to another uk residential address
    And the "Client details" check your answers section should contain:
      | question               | answer                                                      |
      | Correspondence address | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address           | Transport For London\n98 Petty France\nLondon\nSW1H 9EA     |
    When I click Check Your Answers Change link for "correspondence address choice"
    Then I should be on a page with title "Where should we send your client's correspondence?"

    When I choose "My client's UK home address"
    And I click "Save and continue"
    Then I should be on a page with title "Find your client's home address"

    When I click "Find address"
    Then I should be on a page with title "Select your client's home address"

    When I choose "Transport For London, 98 Petty France, London, SW1H 9EA"
    And I click "Use this address"

    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |

    And the "Client details" check your answers section should not contain:
      | question |
      | Correspondence address |
      | Care of recipient |
      | Client has a home address? |

  @javascript @vcr
  Scenario: I am able to change from "My client's UK home address" to "A UK office address"
    Given I complete the passported journey as far as check your answers for client details
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |
    When I click Check Your Answers Change link for "correspondence address choice"
    Then I should be on a page with title "Where should we send your client's correspondence?"

    When I choose "A UK office address"
    And I click "Save and continue"
    Then I should be on a page with title "Enter your client's correspondence address"

    When I enter address line one 'British Transport Police'
    And I enter address line two '98 Petty France'
    And I enter city 'London'
    And I enter a postcode 'SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page with title "Do you want to add a 'care of' recipient for your client's mail?"

    When I choose "Yes, a person"
    And I enter First name "Brian"
    And I enter Last name "Surname"
    And I click "Save and continue"
    Then I should be on a page with title "Does your client have a home address"

    When I choose "Yes"
    And I click "Save and continue"
    Then I should be on a page with title "Find your client's home address"

    When I click "Find address"
    Then I should be on a page with title "Select your client's home address"

    When I choose "Transport For London, 98 Petty France, London, SW1H 9EA"
    And I click "Use this address"

    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question                   | answer                                                      |
      | Correspondence address     | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address               | Transport For London\n98 Petty France\nLondon\nSW1H 9EA     |
      | Care of recipient          | Brian Surname                                               |
      | Client has a home address? | Yes                                                         |

  @javascript @vcr
  Scenario: I am able to change from "A UK office address" to "My client's UK home address"
    Given I complete the passported journey as far as check your answers and send correspondence to a uk office address
    And the "Client details" check your answers section should contain:
      | question               | answer                                                      |
      | Correspondence address | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address           | Transport For London\n98 Petty France\nLondon\nSW1H 9EA     |
    When I click Check Your Answers Change link for "correspondence address choice"
    Then I should be on a page with title "Where should we send your client's correspondence?"

    When I choose "My client's UK home address"
    And I click "Save and continue"
    Then I should be on a page with title "Find your client's home address"

    When I click "Find address"
    Then I should be on a page with title "Select your client's home address"

    When I choose "Transport For London, 98 Petty France, London, SW1H 9EA"
    And I click "Use this address"

    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question | answer |
      | Home address | Transport For London\n98 Petty France\nLondon\nSW1H 9EA |

    And the "Client details" check your answers section should not contain:
      | question |
      | Correspondence address |
      | Care of recipient |
      | Client has a home address? |

  @javascript @vcr
  Scenario: I am able to change from "Another UK residential address" to "A UK office address"
    Given I complete the passported journey as far as check your answers and send correspondence to another uk residential address
    And the "Client details" check your answers section should contain:
      | question               | answer                                                      |
      | Correspondence address | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address           | Transport For London\n98 Petty France\nLondon\nSW1H 9EA     |
    When I click Check Your Answers Change link for "correspondence address choice"
    Then I should be on a page with title "Where should we send your client's correspondence?"

    When I choose "A UK office address"
    And I click "Save and continue"
    Then I should be on a page with title "Enter your client's correspondence address"

    When I enter address line one 'British Transport Police'
    And I enter address line two '98 Petty France'
    And I enter city 'London'
    And I enter a postcode 'SW1H 9EA'
    And I click 'Save and continue'
    Then I should be on a page with title "Do you want to add a 'care of' recipient for your client's mail?"

    When I choose "Yes, a person"
    And I enter First name "Brian"
    And I enter Last name "Surname"
    And I click "Save and continue"
    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question                   | answer                                                      |
      | Correspondence address     | British Transport Police\n98 Petty France\nLondon\nSW1H 9EA |
      | Home address               | Transport For London\n98 Petty France\nLondon\nSW1H 9EA     |
      | Care of recipient          | Brian Surname                                               |
      | Client has a home address? | Yes                                                         |

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
    Then I should be on a page with title "Does your client have a National Insurance number?"

    When I choose "No"
    And I click 'Save and continue'
    Then I should be on a page with title "Check your answers"
    And the "Client details" check your answers section should contain:
      | question | answer |
      | National Insurance number | Not provided |

    And I should not see "What happens next"
    And I should not see "to check their benefit status"

  @javascript @vcr
  Scenario: I want to change the proceeding type from the check your answers page
    Given I complete the journey as far as check your answers
    And I click Check Your Answers Change link for 'Proceedings'
    And I click the first link 'Remove'
    And I search for proceeding 'Non-molestation order'
    Then I choose a 'Non-molestation order' radio button
    Then I click 'Save and continue'
    Then I should be on a page showing 'Do you want to add another proceeding?'
    Then I choose 'No'
    Then I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nWhat is your client's role in this proceeding?'
    When I choose 'Applicant, claimant or petitioner'
    And I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order\nHave you used delegated functions for this proceeding?'
    When I choose 'No'
    When I click 'Save and continue'
    Then I should see 'Proceeding 1\nNon-molestation order'
    And I should see 'Do you want to use the default level of service and scope for the substantive application?'
    When I choose 'Yes'
    And I click 'Save and continue'
    Then I should be on a page showing "What you're applying for"
    Then I should be on a page showing "default substantive cost limit"
    When I click 'Save and continue'
    Then I should be on a page showing 'Check your answers'

  @javascript @vcr
  Scenario: I want to change address manually from the check your answers page
    Given I complete the passported journey as far as check your answers and send correspondence to another uk residential address
    And I click Check Your Answers Change link for 'Address'
    Then I should be on a page showing "Find your client's correspondence address"
    Then I enter a postcode 'XX1 1XX'
    Then I click find address
    Then I click link "Enter an address manually"
    Then I enter address line one 'Fake Road'
    Then I enter city 'Fake City'
    Then I enter postcode 'XX1 1XX'
    Then I click 'Save and continue'
    Then I should be on a page with title "Do you want to add a 'care of' recipient for your client's mail?"
    When I choose "No"
    And I click "Save and continue"
    Then I should be on a page showing 'Check your answers'
