@javascript @stub_office_address_retriever
Feature: Review and print your application

  Scenario: For a non-passported bank statement upload journey
    Given I have completed a bank statement upload application with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      # Client details and what they are applying for
      | h2  | Client and case details |

      | h3  | Client |
      | h4  | Client details |

      | h3  | Cases linked to this one |
      | h4  | Linking |
      | h4  | All applications with a family link to this one |
      | h4  | Copying |

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

      | h3  | Housing Benefit |
      | h4  | Housing Benefit details |

      | h3  | Dependants |

      # Capital assessment
      | h2  | Capital and assets |

      | h3  | Your client's capital |
      | h4  | Property |
      | h4  | Your client's property |

      | h3  | Vehicles |
      | h4  | Vehicles owned |
      | h4  | Vehicle 1 |

      | h3  | Bank accounts |
      | h4  | Your client's accounts |

      | h3  | Savings and assets |
      | h4  | Your client's savings or investments |
      | h4  | Your client's assets |
      | h4  | Restrictions on your client's assets |
      | h4  | One-off payments your client received |

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
    Given I have completed truelayer application with merits
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

      # Means assessment
      | h2  | Financial assessment |

      | h3  | Your client's income |
      | h4  | Payments your client gets |
      | h4  | Student finance |

      | h3  | Your client's outgoings |
      | h4  | Payments your client pays |

      | h3  | Dependants |

      # Capital assessment
      | h2  | Capital and assets |

      | h3  | Your client's capital |
      | h4  | Property |
      | h4  | Your client's property |

      | h3  | Vehicles |
      | h4  | Vehicles owned |
      | h4  | Vehicle 1 |

      | h3  | Bank accounts |
      | h4  | Your client's offline accounts |

      | h3  | Savings and assets |
      | h4  | Your client's savings or investments |
      | h4  | Your client's assets |
      | h4  | Restrictions on your client's assets |
      | h4  | One-off payments your client received |

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
      | h4  | Bank statements |
      | h4  | Client benefits, charitable or government payments |

      | h3  | Housing Benefit |

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
      | h2  | Financial assessment |

      | h3  | Your client's capital |
      | h4  | Property |
      | h4  | Your client's property |

      | h3  | Vehicles |
      | h4  | Vehicles owned |
      | h4  | Vehicle 1 |

      | h3  | Bank accounts |
      | h4  | Your client's accounts |

      | h3  | Savings and assets |
      | h4  | Your client's savings or investments |
      | h4  | Your client's assets |
      | h4  | Restrictions on your client's assets |
      | h4  | One-off payments your client received |

      # This is only in legacy policy disregards (shared/check_answers/_one_link_section.html.erb)
      | h2  | Payments from scheme or charities |

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

    And I should see 'Print the application and get your client to sign the declaration.'
    And I should not see 'Print the application and get the person acting for'

    And I should not see any change links

  Scenario: For a non-means tested journey
    Given I have completed a non-means-tested journey with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client and case details |
      | h3  | Client |
      | h3  | What you're applying for |
      | h2  | Merits |
      | h3  | Inherent jurisdiction high court injunction |
      | h3  | Print your application |

    And I should see 'Print the application and get the person acting for'
    And I should see "For example, a litigation friend, a professional children's guardian or a parental order report."

    Then the following sections should not exist:
      | tag | section |
      | h4  | Income |
      | h3  | Your client's capital |
      | h4  | Regular payments |

    And I should not see any change links

  Scenario: For a backdated SCA journey
    Given I have completed a backdated special children act journey
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h1  | Print and submit your application |
      | h2  | Client and case details |

      | h3  | Client |
      | h3  | What you're applying for |

      | h2  | Merits |
      | h3  | Case details |

      | h3  | Print or save your application |

    And I should see 'Delegated functions'
    And I should not see 'Email address'
    And I should not see 'Emergency level of service'
    And I should not see 'Emergency scope limits'

    And the following sections should not exist:
      | tag | section |
      | h3  | Your client's capital |
      | h3  | Emergency cost limit |

    And I should not see any change links
    And I should see "You'll need to keep a copy of the application on file, along with any evidence you included."
    And I should not see "Print the application and get the person acting for"

