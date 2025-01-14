@javascript
Feature: Review and print your application

  Scenario: For a non-passported bank statement upload journey with a partner
    Given I have completed a non-passported employed with partner application with bank statement uploads
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Partner's details |
      | h2  | What you're applying for |
      | h2  | What you're applying for |
      | h2  | Extend, variation or discharge - Part IV |
      | h2  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h2  | Emergency cost limit |
      | h2  | Your client's income |
      | h3  | Bank statements |
      | h3  | Employment income |
      | h3  | Client benefits, charitable or government payments |
      | h3  | Payments your client gets |
      | h3  | Payments your client gets in cash |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client pays in cash|
      | h2  | The partner's income |
      | h3  | Partner benefits, charitable or government payments |
      | h3  | Payments the partner gets |
      | h3  | Payments the partner gets in cash |
      | h2  | The partner's outgoings |
      | h3  | Payments the partner pays |
      | h3  | Payments the partner pays in cash|
      | h3  | Housing Benefit |
      | h2  | Your client and their partner's capital |
      | h3  | Property |
      | h3  | Your client's and their partner's property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h2  | Which savings or investments does either your client or their partner have? |
      | h2  | Which assets does either your client or their partner have? |
      | h2  | Restrictions on your client's or their partner's assets |
      | h2  | One-off payments your client or their partner received |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponents |
      | h2  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Income, regular payments and assets |
      | h3  | Income |
      | h3  | Regular payments |

  Scenario: For a non-passported truelayer bank transactions journey
    Given I have completed a non-passported with partner application with truelayer
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Partner's details |
      | h2  | What you're applying for |
      | h2  | What you're applying for |
      | h2  | Extend, variation or discharge - Part IV |
      | h2  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h2  | Emergency cost limit |
      | h2  | Income, regular payments and assets |
      | h3  | Income |
      | h3  | Regular payments |
      | h2  | The partner's income |
      | h3  | Payments the partner gets |
      | h3  | Payments the partner gets in cash |
      | h3  | Student finance |
      | h2  | The partner's outgoings |
      | h3  | Payments the partner pays |
      | h3  | Payments the partner pays in cash|
      | h3  | Property |
      | h3  | Your client's and their partner's property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h2  | Which savings or investments does either your client or their partner have? |
      | h2  | Which assets does either your client or their partner have? |
      | h2  | Restrictions on your client's or their partner's assets |
      | h2  | One-off payments your client or their partner received |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponents |
      | h2  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Payments your client gets |
      | h3  | Payments your client gets in cash |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client pays in cash|
      | h2  | Your client's capital |

  Scenario: For a passported journey
    Given I have completed a passported application with a partner with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | What you're applying for |
      | h2  | What you're applying for |
      | h2  | Extend, variation or discharge - Part IV |
      | h2  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h2  | Emergency cost limit |
      | h2  | Income, regular payments and assets |
      | h3  | Income |
      | h3  | Regular payments |
      | h3  | Property |
      | h3  | Your client's and their partner's property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h2  | Which savings or investments does either your client or their partner have? |
      | h2  | Which assets does either your client or their partner have? |
      | h2  | Restrictions on your client's or their partner's assets |
      | h2  | One-off payments your client or their partner received |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponents |
      | h2  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Employment income |
      | h3  | Payments your client gets |
      | h3  | Payments your client gets in cash |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client pays in cash|
      | h2  | The partner's income |
      | h3  | Payments the partner gets |
      | h3  | Payments the partner gets in cash |
      | h2  | The partner's outgoings |
      | h3  | Payments the partner pays |
      | h3  | Payments the partner pays in cash|
      | h2  | Your client's capital |

    And I should see "Passported"

    And I should see 'Print the application and get your client and their partner to sign the declaration.'
    And I should not see 'Print the application and get the person acting for'



