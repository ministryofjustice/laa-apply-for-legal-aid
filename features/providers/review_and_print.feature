@javascript
Feature: Review and print your application

  Scenario: For a non-passported bank statement upload journey
    Given I have completed a bank statement upload application with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | What you're applying for |
      | h2  | Delegated functions |
      | h2  | Covered under a substantive certificate |

  Scenario: For a non-passported enhanced bank statement upload journey
    Given the feature flag for enhanced_bank_upload is enabled
    And I have completed an enhanced bank statement upload application with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | What you're applying for |

  Scenario: For a non-passported truelayer bank transactions journey
    Given I have completed truelayer application with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | What you're applying for |
      | h2  | Delegated functions |
      | h2  | Covered under an emergency certificate |
      | h2  | Covered under a substantive certificate |
      | h2  | Emergency cost limit |
      | h2  | Income, regular payments and assets |
      | h3  | Income |
      | h3  | Regular payments |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does your client have? |
      | h3  | Does your client have any savings accounts they cannot access online? |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponent details |
      | h2  | Variation or discharge under section 5 protection from harassment act 1997r |
      | h2  | Extend, variation or discharge - Part IV |
      | h1  | Print your application |

  Scenario: For a passported journey
    Given I have completed a passported application with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | What you're applying for |
      | h2  | Delegated functions |
      | h2  | Covered under an emergency certificate |
      | h2  | Covered under a substantive certificate |
      | h2  | Emergency cost limit |
      | h2  | Income, regular payments and assets |
      | h3  | Income |
      | h3  | Regular payments |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does your client have? |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponent details |
      | h2  | Variation or discharge under section 5 protection from harassment act 1997r |
      | h2  | Extend, variation or discharge - Part IV |
      | h1  | Print your application |
