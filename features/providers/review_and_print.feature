@javascript
Feature: Review and print your application

  Scenario: For a non-passported bank statement upload journey
    Given I have completed a bank statement upload application with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client |
      | h3  | Client details |

      | h2  | Cases linked to this one |
      | h3  | Linking |
      | h3  | All applications with a family link to this one |
      | h3  | Copying |

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

      | h2  | Housing Benefit |
      | h3  | Housing Benefit details |

      | h2  | Dependants |

      # Capital assessment
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Your client's property |

      | h2  | Vehicles |
      | h3  | Vehicles owned |
      | h3  | Vehicle 1 |

      | h2  | Bank accounts |
      | h3  | Your client's accounts |

      | h2  | Savings and assets |
      | h3  | Your client's savings or investments |
      | h3  | Your client's assets |
      | h3  | Restrictions on your client's assets |
      | h3  | One-off payments your client received |

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
    Given I have completed truelayer application with merits
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

      # Means assessment
      | h2  | Your client's income |
      | h3  | Payments your client gets |
      | h3  | Student finance |

      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |

      | h2  | Dependants |

      # Capital assessment
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Your client's property |

      | h2  | Vehicles |
      | h3  | Vehicles owned |
      | h3  | Vehicle 1 |

      | h2  | Bank accounts |
      | h3  | Your client's offline accounts |

      | h2  | Savings and assets |
      | h3  | Your client's savings or investments |
      | h3  | Your client's assets |
      | h3  | Restrictions on your client's assets |
      | h3  | One-off payments your client received |

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
      | h3  | Bank statements |
      | h3  | Client benefits, charitable or government payments |

      | h2  | Housing Benefit |

    And the "Payments your client gets" review section should contain:
      | question |
      | Benefits, charitable or government payments |
      | Financial help from friends or family |
      | Maintenance payments from a former partner |
      | Income from a property or lodger |
      | Pension |

    And I should not see "Housing Benefit total"

    And I should see "Housing payments"
    And I should see "Childcare payments"
    And I should see "Maintenance payments to a former partner"
    And I should see "Payments towards legal aid in a criminal case"
    And I should not see any change links

  Scenario: For a non-passported truelayer bank transactions journey without student finance
    Given I have completed truelayer application with merits and no student finance
    When I view the review and print your application page
    Then I should not see "Amount of student finance"
    And the answer for 'applicant student finance question' should be 'No'
    And I should not see any change links

  Scenario: For a passported journey
    Given I have completed a passported application with merits
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
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Your client's property |

      | h2  | Vehicles |
      | h3  | Vehicles owned |
      | h3  | Vehicle 1 |

      | h2  | Bank accounts |
      | h3  | Your client's accounts |

      | h2  | Savings and assets |
      | h3  | Your client's savings or investments |
      | h3  | Your client's assets |
      | h3  | Restrictions on your client's assets |
      | h3  | One-off payments your client received |
      | h3  | Payments from scheme or charities |

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
      | h3  | Housing Benefit details |

      | h2  | Dependants |
      | h3  | Any dependants |

    And I should see 'Print the application and get your client to sign the declaration.'
    And I should not see 'Print the application and get the person acting for'

    And I should not see any change links

  Scenario: For a non-means tested journey
    Given I have completed a non-means-tested journey with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client |
      | h2  | What you're applying for |
      | h2  | Inherent jurisdiction high court injunction |
      | h2  | Print your application |

    And I should see 'Print the application and get the person acting for'
    And I should see "For example, a litigation friend, a professional children's guardian or a parental order report."

    Then the following sections should not exist:
      | tag | section |
      | h3  | Income |
      | h2  | Your client's capital |
      | h3  | Regular payments |

    And I should not see any change links

  Scenario: For a backdated SCA journey
    Given I have completed a backdated special children act journey
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h1  | Print and submit your application |
      | h2  | Client |
      | h2  | What you're applying for |
      | h2  | Case details |
      | h2  | Print your application |

    And I should see 'Delegated functions'
    And I should not see 'Email address'
    And I should not see 'Emergency level of service'
    And I should not see 'Emergency scope limits'

    And the following sections should not exist:
      | tag | section |
      | h2  | Your client's capital |
      | h2  | Emergency cost limit |

    And I should not see any change links
    And I should see "You'll need to keep a copy of the application on file, along with any evidence you included."
    And I should not see "Print the application and get the person acting for"

