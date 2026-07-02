@javascript @stub_office_address_retriever
Feature: Review and print your application

  Scenario: For a non-passported bank statement upload journey with a partner
    Given I have completed a non-passported employed with partner application with bank statement uploads
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client and case details |

      | h3  | Client |
      | h4  | Client details |

      | h3  | Partner |
      | h4  | Partner's details |

      | h3  | Cases linked to this one |
      | h4  | Linking |

      | h3  | What you're applying for |
      | h4  | Extend, variation or discharge - Part IV |
      | h4  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h4  | Cost limits |

      # Means assessment
      | h2  | Financial assessment |

      | h3  | Your client's income |
      | h4  | Bank statements |
      | h4  | Client benefits, charitable or government payments |
      | h4  | Payments your client gets |
      | h4  | Payments your client gets in cash |
      | h4  | Student finance |

      | h3  | Your client's outgoings |
      | h4  | Payments your client pays |
      | h4  | Payments your client pays in cash|

      | h3  | The partner's income |
      | h4  | Bank statements |
      | h4  | Partner benefits, charitable or government payments |
      | h4  | Payments the partner gets |
      | h4  | Payments the partner gets in cash |
      | h4  | Student finance |

      | h3  | The partner's outgoings |
      | h4  | Payments the partner pays |
      | h4  | Payments the partner pays in cash|

      | h3  | Housing Benefit |
      | h4  | Housing Benefit details |

      | h3  | Dependants |

      # Capital assessment
      | h2  | Capital and assets |

      | h3  | Your client and their partner's capital |
      | h4  | Property |
      | h4  | Your client and their partner's property |

      | h3  | Vehicles |
      | h4  | Vehicles owned |
      | h4  | Vehicle 1 |

      | h3  | Bank accounts |
      | h4  | Your client's accounts |
      | h4  | The partner's accounts |

      | h3  | Savings and assets |
      | h4  | Your client or their partner's savings or investments |
      | h4  | Your client or their partner's assets |
      | h4  | Restrictions on your client or their partner's assets |
      | h4  | One-off payments your client or their partner received |
      | h4  | Disregarded payment 1 |
      | h4  | Payment to be reviewed 1 |

      # Merits assessment
      | h2  | Merits |

      | h3  | Case details |
      | h4  | Latest incident details |
      | h4  | Opponents |
      | h4  | Mental capacity |
      | h4  | Domestic abuse summary |
      | h4  | Statement of case |

      | h3  | Extend, variation or discharge - Part IV |
      | h4  | Chances of success |

      | h3  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h4  | Chances of success |

      | h3  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      # Not shown on the review and print page
      | h4  | Proceedings |
      | h4  | Any dependants |

    And I should not see any change links

  Scenario: For a non-passported truelayer bank transactions journey
    Given I have completed a non-passported with partner application with truelayer
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client and case details |

      | h3  | Client |
      | h4  | Client details |

      | h3  | Partner |
      | h4  | Partner's details |

      | h3  | Cases linked to this one |
      | h4  | Linking |

      | h3  | What you're applying for |
      | h4  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h4  | Extend, variation or discharge - Part IV |
      | h4  | Cost limits |

      # Means assessment
      | h2  | Financial assessment |

      | h3  | Your client's income |
      | h4  | Payments your client gets |
      | h4  | Student finance |

      | h3  | Your client's outgoings |
      | h4  | Payments your client pays |

      | h3  | The partner's income |
      | h4  | Bank statements |
      | h4  | Partner benefits, charitable or government payments |
      | h4  | Payments the partner gets |
      | h4  | Payments the partner gets in cash |
      | h4  | Student finance |

      | h3  | The partner's outgoings |
      | h4  | Payments the partner pays |
      | h4  | Payments the partner pays in cash|

      | h3  | Dependants |

      # Capital assessment
      | h2  | Capital and assets |

      | h3  | Your client and their partner's capital |
      | h4  | Property |
      | h4  | Your client and their partner's property |

      | h3  | Vehicles |
      | h4  | Vehicles owned |
      | h4  | Vehicle 1 |

      | h3  | Bank accounts |
      | h4  | Client's bank accounts |
      | h4  | Money in bank accounts |
      | h4  | The partner's accounts |
      | h4  | Your client's offline accounts |

      | h3  | Savings and assets |
      | h4  | Your client or their partner's savings or investments |
      | h4  | Your client or their partner's assets |
      | h4  | Restrictions on your client or their partner's assets |
      | h4  | One-off payments your client or their partner received |
      | h4  | Disregarded payment 1 |
      | h4  | Payment to be reviewed 1 |

      # Merits assessment
      | h2  | Merits |

      | h3  | Case details |
      | h4  | Latest incident details |
      | h4  | Opponents |
      | h4  | Mental capacity |
      | h4  | Domestic abuse summary |
      | h4  | Statement of case |

      | h3  | Extend, variation or discharge - Part IV |
      | h4  | Chances of success |

      | h3  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h4  | Chances of success |

      | h3  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      # Not shown on the review and print page
      | h4  | Proceedings |
      | h4  | Any dependants |
      | h3  | Your client's capital |

  Scenario: For a passported journey
    Given I have completed a passported application with a partner with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client and case details |

      | h3  | Client |
      | h4  | Client details |

      | h3  | Cases linked to this one |
      | h4  | Linking |

      | h3  | What you're applying for |
      | h4  | Extend, variation or discharge - Part IV |
      | h4  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h4  | Cost limits |

      # Capital assessment
      | h2  | Capital and assets |

      | h3  | Your client and their partner's capital |
      | h4  | Property |
      | h4  | Your client and their partner's property |

      | h3  | Vehicles |
      | h4  | Vehicles owned |
      | h4  | Vehicle 1 |

      | h3  | Bank accounts |
      | h4  | Your client's accounts |
      | h4  | The partner's accounts |
      | h4  | Joint accounts |

      | h3  | Savings and assets |
      | h4  | Your client or their partner's savings or investments |
      | h4  | Your client or their partner's assets |
      | h4  | Restrictions on your client or their partner's assets |
      | h4  | One-off payments your client or their partner received |

      # Merits assessment
      | h2  | Merits |

      | h3  | Case details |
      | h4  | Latest incident details |
      | h4  | Opponents |
      | h4  | Mental capacity |
      | h4  | Domestic abuse summary |
      | h4  | Statement of case |

      | h3  | Extend, variation or discharge - Part IV |
      | h4  | Chances of success |

      | h3  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h4  | Chances of success |

      | h3  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      | h3  | Your client's income |
      | h4  | Employment income |
      | h4  | Payments your client gets |
      | h4  | Payments your client gets in cash |
      | h4  | Student finance |

      | h3  | Your client's outgoings |
      | h4  | Payments your client pays |
      | h4  | Payments your client pays in cash|

      | h3  | Housing Benefit |
      | h4  | Housing Benefit details |

      | h3  | Dependants |
      | h4  | Any dependants |

    Then the following sections should not exist:
      | tag | section |
      | h3  | Your client's income |
      | h4  | Employment income |
      | h4  | Payments your client gets |
      | h4  | Payments your client gets in cash |
      | h4  | Student finance |

      | h3  | Your client's outgoings |
      | h4  | Payments your client pays |
      | h4  | Payments your client pays in cash|

      | h3  | The partner's income |
      | h4  | Payments the partner gets |
      | h4  | Payments the partner gets in cash |

      | h3  | The partner's outgoings |
      | h4  | Payments the partner pays |
      | h4  | Payments the partner pays in cash|

      | h3  | Housing Benefit |
      | h4  | Housing Benefit details |

      | h3  | Dependants |
      | h4  | Any dependants |

      | h3  | Your client's capital |

    And I should see 'Print the application and get your client and their partner to sign the declaration.'
    And I should not see 'Print the application and get the person acting for'



