@javascript
Feature: Review and print your application

  Scenario: For a non-passported bank statement upload journey with a partner
    Given I have completed a non-passported employed with partner application with bank statement uploads
    And the feature flag for linked_applications is enabled
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client |
      | h3  | Client details |

      | h2  | Partner |
      | h3  | Partner's details |

      | h2  | Cases linked to this one |
      | h3  | Linking |

      | h2  | What you're applying for |
      | h3  | Extend, variation or discharge - Part IV |
      | h3  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h3  | Cost limits |

      # Means assessment
      | h2  | Your client's income |
      | h3  | Bank statements |
      | h3  | Client benefits, charitable or government payments |
      | h3  | Payments your client gets |
      | h3  | Payments your client gets in cash |
      | h3  | Student finance |

      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client pays in cash|

      | h2  | The partner's income |
      | h3  | Bank statements |
      | h3  | Employment income |
      | h3  | Partner benefits, charitable or government payments |
      | h3  | Payments the partner gets |
      | h3  | Payments the partner gets in cash |
      | h3  | Student finance |

      | h2  | The partner's outgoings |
      | h3  | Payments the partner pays |
      | h3  | Payments the partner pays in cash|

      | h2  | Housing benefit |
      | h3  | Housing benefit details |

      | h2  | Dependants |

      # Capital assessment
      | h2  | Your client and their partner's capital |
      | h3  | Property |
      | h3  | Your client and their partner's property |

      | h2  | Vehicles |
      | h3  | Vehicles owned |
      | h3  | Vehicle 1 |

      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h3  | The partner's accounts |

      | h2  | Savings and assets |
      | h3  | Your client or their partner's savings or investments |
      | h3  | Your client or their partner's assets |
      | h3  | Restrictions on your client or their partner's assets |
      | h3  | One-off payments your client or their partner received |
      | h3  | Disregarded payment 1 |
      | h3  | Payment to be reviewed 1 |

      # Merits assessment
      | h2  | Case details |
      | h3  | Latest incident details |
      | h3  | Opponents |
      | h3  | Mental capacity |
      | h3  | Domestic abuse summary |
      | h3  | Statement of case |

      | h2  | Extend, variation or discharge - Part IV |
      | h3  | Chances of success |

      | h2  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h3  | Chances of success |

      | h2  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      # Not shown on the review and print page
      | h3  | Proceedings |
      | h3  | Any dependants |

    And I should not see any change links

  Scenario: For a non-passported truelayer bank transactions journey
    Given I have completed a non-passported with partner application with truelayer
    And the feature flag for linked_applications is enabled
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client |
      | h3  | Client details |

      | h2  | Partner |
      | h3  | Partner's details |

      | h2  | Cases linked to this one |
      | h3  | Linking |

      | h2  | What you're applying for |
      | h3  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h3  | Extend, variation or discharge - Part IV |
      | h3  | Cost limits |

      # Means assessment
      | h2  | Your client's income |
      | h3  | Payments your client gets |
      | h3  | Student finance |

      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |

      | h2  | The partner's income |
      | h3  | Bank statements |
      | h3  | Employment income |
      | h3  | Partner benefits, charitable or government payments |
      | h3  | Payments the partner gets |
      | h3  | Payments the partner gets in cash |
      | h3  | Student finance |

      | h2  | The partner's outgoings |
      | h3  | Payments the partner pays |
      | h3  | Payments the partner pays in cash|

      | h2  | Dependants |

      # Capital assessment
      | h2  | Your client and their partner's capital |
      | h3  | Property |
      | h3  | Your client and their partner's property |

      | h2  | Vehicles |
      | h3  | Vehicles owned |
      | h3  | Vehicle 1 |

      | h2  | Bank accounts |
      | h3  | Client's bank accounts |
      | h3  | Money in bank accounts |
      | h3  | The partner's accounts |
      | h3  | Your client's offline accounts |

      | h2  | Savings and assets |
      | h3  | Your client or their partner's savings or investments |
      | h3  | Your client or their partner's assets |
      | h3  | Restrictions on your client or their partner's assets |
      | h3  | One-off payments your client or their partner received |
      | h3  | Disregarded payment 1 |
      | h3  | Payment to be reviewed 1 |

      # Merits assessment
      | h2  | Case details |
      | h3  | Latest incident details |
      | h3  | Opponents |
      | h3  | Mental capacity |
      | h3  | Domestic abuse summary |
      | h3  | Statement of case |

      | h2  | Extend, variation or discharge - Part IV |
      | h3  | Chances of success |

      | h2  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h3  | Chances of success |

      | h2  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      # Not shown on the review and print page
      | h3  | Proceedings |
      | h3  | Any dependants |
      | h2  | Your client's capital |

  Scenario: For a passported journey
    Given I have completed a passported application with a partner with merits
    And the feature flag for linked_applications is enabled
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client |
      | h3  | Client details |

      | h2  | Cases linked to this one |
      | h3  | Linking |

      | h2  | What you're applying for |
      | h3  | Extend, variation or discharge - Part IV |
      | h3  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h3  | Cost limits |

      # Capital assessment
      | h2  | Your client and their partner's capital |
      | h3  | Property |
      | h3  | Your client and their partner's property |

      | h2  | Vehicles |
      | h3  | Vehicles owned |
      | h3  | Vehicle 1 |

      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h3  | The partner's accounts |
      | h3  | Joint accounts |

      | h2  | Savings and assets |
      | h3  | Your client or their partner's savings or investments |
      | h3  | Your client or their partner's assets |
      | h3  | Restrictions on your client or their partner's assets |
      | h3  | One-off payments your client or their partner received |

      # Merits assessment
      | h2  | Case details |
      | h3  | Latest incident details |
      | h3  | Opponents |
      | h3  | Mental capacity |
      | h3  | Domestic abuse summary |
      | h3  | Statement of case |

      | h2  | Extend, variation or discharge - Part IV |
      | h3  | Chances of success |

      | h2  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h3  | Chances of success |

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

      | h2  | Housing Benefit |
      | h3  | Housing benefit details |

      | h2  | Dependants |
      | h3  | Any dependants |

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

      | h2  | Housing Benefit |
      | h3  | Housing benefit details |

      | h2  | Dependants |
      | h3  | Any dependants |

      | h2  | Your client's capital |

    And I should see 'Print the application and get your client and their partner to sign the declaration.'
    And I should not see 'Print the application and get the person acting for'



