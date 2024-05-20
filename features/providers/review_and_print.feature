@javascript
Feature: Review and print your application

  Scenario: For a non-passported bank statement upload journey
    Given I have completed a bank statement upload application with merits
    And the feature flag for linked_applications is enabled
    When I view the review and print your application page
    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Cases linked to this one |
      | h2  | All applications with a family link to this one |
      | h2  | Copying |
      | h2  | What you're applying for |
      | h2  | What you're applying for |
      | h2  | Extend, variation or discharge - Part IV |
      | h2  | Variation or discharge under section 5 protection from harassment act 1997 |
      | h2  | Emergency cost limit |
      | h3  | Bank statements |
      | h2  | Your client's income |
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Payments your client receives in cash |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h3  | Payments your client makes in cash|
      | h3  | Housing Benefit |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponent details |
      | h1  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Income, regular payments and assets |
      | h3  | Income |
      | h3  | Regular payments |

  Scenario: For a non-passported truelayer bank transactions journey
    Given I have completed truelayer application with merits
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
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponent details |
      | h1  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Payments your client receives in cash |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h3  | Payments your client makes in cash|
      | h2  | Your client's capital |

    And the "Income, regular payments and assets" review section should contain:
      | question |
      | Benefits total |
      | Disregarded benefits total |
      | Financial help from friends or family total |
      | Maintenance payments from a former partner total |
      | Income from a property or lodger total |
      | Pension total |
      | Student loan |

    And I should not see "Housing benefit total"

    And I should see "Housing payments"
    And I should see "Childcare payments"
    And I should see "Maintenance payments to a former partner"
    And I should see "Payments towards legal aid in a criminal case"

  Scenario: For a non-passported truelayer bank transactions journey without student finance
    Given I have completed truelayer application with merits and no student finance
    When I view the review and print your application page
    Then I should not see "Student loan"
    And the answer to the "Does your client get student finance?" question should be "No"

  Scenario: For a passported journey
    Given I have completed a passported application with merits
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
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h2  | Case details |
      | h2  | Latest incident details |
      | h2  | Opponent details |
      | h1  | Print your application |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Payments your client receives in cash |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h3  | Payments your client makes in cash|
      | h2  | Your client's capital |

    And I should see "Passported"
    And I should not see "Benefits total"
    And I should not see "Housing benefit total"
    And I should not see "Disregarded benefits total"
    And I should not see "Financial help from friends or family total"
    And I should not see "Maintenance payments from a former partner total"
    And I should not see "Income from a property or lodger total"
    And I should not see "Pension total"

    And I should not see "Housing payments"
    And I should not see "Childcare payments"
    And I should not see "Maintenance payments to a former partner"
    And I should not see "Payments towards legal aid in a criminal case"

    And I should see 'Print the application and get your client to sign the declaration.'
    And I should not see 'Print the application and get the person acting for'

  Scenario: For a non-means tested journey
    Given I have completed a non-means tested journey with merits
    When I view the review and print your application page

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | What you're applying for |
      | h2  | Inherent jurisdiction high court injunction |
      | h2  | Income, regular payments and assets |
      | h1  | Print your application |

    And I should see 'Non means tested'
    And I should see 'Print the application and get the person acting for'
    And I should see 'For example, a litigation friend, a professional children’s guardian or a parental order report.'

    Then the following sections should not exist:
      | tag | section |
      | h3  | Income |
      | h3  | Regular payments |
      | h2  | Your client's capital |


