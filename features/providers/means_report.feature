@javascript
Feature: Means report

  Scenario: For a non-passported bank statement upload journey
    Given I have completed a non-passported employed application with bank statement uploads
    When I view the means report

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Passported means |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Declared cash income |
      | h2  | Dependants |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |
      | h3  | Employment notes |
      | h3  | Employment income |
      | h2  | Caseworker Review |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Property, savings and other assets |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h3  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h3  | Bank statements |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Income result |
      | h2  | Income |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Capital result |

    And the Client details questions should exist:
      | question |
      | First name |
      | Last name |
      | Date of birth |
      | Age at computation date |
      | National Insurance number |

    And the Declared income categories questions should exist:
      | question |
      | Benefits |
      | Financial help from friends or family |
      | Maintenance payments from a former partner |
      | Income from a property or lodger |
      | Pension |

    And the Student finance questions should exist:
      | question |
      | Student loan or grant (per year) |

    # TODO: setup cash incomes for test application
    # Then the Declared cash income questions should exist:
    #  | question |
    #  | Benefits |

    And the Dependants questions should exist:
      | question |
      | Child dependants |
      | Adult dependants |

    And the Dependants detail questions should exist:
      | question |
      | Name |
      | Date of birth |
      | What is their relationship to your client? |
      | Are they in full-time education or training? |
      | Do they receive any income? |
      | Do they have assets worth more than £8,000? |

    And the Declared outgoings categories questions should exist:
      | question |
      | Housing payments |
      | Childcare payments |
      | Maintenance payments to a former partner |
      | Payments towards legal aid in a criminal case |

    # TODO: setup cash outgoings for test application
    # Then the Declared cash outgoings questions should exist:
    #  | question |
    #  | Housing payments |

    And the Employment notes questions should exist:
      | question |
      | Do you need to tell us anything else about your client's employment? |
      | Details |

    And the Employment income questions should exist:
      | question |
      | Your client's employment details |

    And the Caseworker review questions should exist:
      | question |
      | Caseworker review required? |
      | Review reasons |

    And the Property questions should exist:
      | question |
      | Does your client own the home they live in? |
      | How much is your client's home worth? |
      | What is the outstanding mortgage on your client's home? |
      | Does your client own their home with anyone else? |
      | What % share of their home does your client legally own? |

    And the Vehicles questions should exist:
      | question |
      | Does your client own a vehicle? |
      | What is the estimated value of the vehicle? |
      | Are there any payments left on the vehicle? |
      | The vehicle was bought more than three years ago? |
      | Is the vehicle in regular use? |

    And the "Which savings or investments does your client have?" questions should exist:
      | question |
      | Money not in a bank account |
      | Access to another person's bank account |
      | ISAs, National Savings Certificates and Premium Bonds |
      | Shares in a PLC |
      | PEPs, unit trusts, capital bonds and government stocks |
      | Life assurance and endowment policies not linked to a mortgage |

    And the "Which assets does your client have?" questions should exist:
      | question |
      | Second property or holiday home estimated value |
      | Second property or holiday home outstanding mortgage amount |
      | Second property or holiday home percentage owned |
      | Timeshare property |
      | Land |
      | Any valuable items worth £500 or more |
      | Money or assets from the estate of a person who has died |
      | Money owed to them, including from a private mortgage |
      | Interest in a trust |

    And the "Restrictions on your client's assets" questions should exist:
      | question |
      | Is your client prohibited from selling or borrowing against their assets? |
      | Details of restrictions |

    And the "Payments from scheme or charities" questions should exist:
      | question |
      | England Infected Blood Support Scheme |
      | Vaccine Damage Payments Scheme |
      | Variant Creutzfeldt-Jakob disease (vCJD) Trust |
      | Criminal Injuries Compensation Scheme |
      | National Emergencies Trust (NET) |
      | We Love Manchester Emergency Fund |
      | The London Emergencies Trust |

    And the "Bank statements" questions should exist:
      | question |
      | Upload bank statements |

  Scenario: For a non-passported truelayer bank transactions journey
    Given I have completed a non-passported application with truelayer
    When I view the means report

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Proceeding eligibility |
      | h2  | Passported means |
      | h2  | Income result |
      | h2  | Income |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Caseworker Review |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Property, savings and other assets |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h3  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Declared cash income |
      | h2  | Dependants |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |
      | h3  | Bank statements |

    And the Client details questions should exist:
      | question |
      | First name |
      | Last name |
      | Date of birth |
      | Age at computation date |
      | National Insurance number |

    And the Proceeding eligibility questions should exist:
      | question |
      | Extend, variation or discharge - Part IV |
      | Variation or discharge under section 5 protection from harassment act 1997r |

    And the Income result questions should exist:
      | question |
      | Total gross income assessed |
      | Total disposable income assessed |
      | Gross income limit |
      | Disposable income lower limit |
      | Disposable income upper limit |
      | Income contribution |

    And the Income questions should exist:
      | question |
      | Benefits |
      | Financial help from friends or family |
      | Maintenance payments |
      | Income from property or lodger |
      | Student loan or grant |
      | Pension |
      | Total income |

    And the Outgoings questions should exist:
      | question |
      | Housing payments |
      | Childcare payments |
      | Maintenance payments to a former partner |
      | Payments towards legal aid in a criminal cas |
      | Total outgoings |

    And the Deductions questions should exist:
      | question |
      | Dependants allowance |
      | Income from benefits excluded from calculation |
      | Total deductions |

    And the Caseworker review questions should exist:
      | question |
      | Caseworker review required? |
      | Review reasons |

    And the Capital result questions should exist:
      | question |
      | Total capital assessed |
      | Capital lower limit |
      | Capital upper limit |
      | Capital contribution |

    And the Property questions should exist:
      | question |
      | Does your client own the home they live in? |
      | How much is your client's home worth? |
      | What is the outstanding mortgage on your client's home? |
      | Does your client own their home with anyone else? |
      | What % share of their home does your client legally own? |

    And the Vehicles questions should exist:
      | question |
      | Does your client own a vehicle? |
      | What is the estimated value of the vehicle? |
      | Are there any payments left on the vehicle? |
      | The vehicle was bought more than three years ago? |
      | Is the vehicle in regular use? |

    And the "Which savings or investments does your client have?" questions should exist:
      | question |
      | Money not in a bank account |
      | Access to another person's bank account |
      | ISAs, National Savings Certificates and Premium Bonds |
      | Shares in a PLC |
      | PEPs, unit trusts, capital bonds and government stocks |
      | Life assurance and endowment policies not linked to a mortgage |

    And the "Which assets does your client have?" questions should exist:
      | question |
      | Second property or holiday home estimated value |
      | Second property or holiday home outstanding mortgage amount |
      | Second property or holiday home percentage owned |
      | Timeshare property |
      | Land |
      | Any valuable items worth £500 or more |
      | Money or assets from the estate of a person who has died |
      | Money owed to them, including from a private mortgage |
      | Interest in a trust |

    And the "Restrictions on your client's assets" questions should exist:
      | question |
      | Is your client prohibited from selling or borrowing against their assets? |
      | Details of restrictions |

    And the "Payments from scheme or charities" questions should exist:
      | question |
      | England Infected Blood Support Scheme |
      | Vaccine Damage Payments Scheme |
      | Variant Creutzfeldt-Jakob disease (vCJD) Trust |
      | Criminal Injuries Compensation Scheme |
      | National Emergencies Trust (NET) |
      | We Love Manchester Emergency Fund |
      | The London Emergencies Trust |

  Scenario: For a passported journey
    Given I have completed a passported application
    When I view the means report

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Proceeding eligibility |
      | h2  | Passported means |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Which bank accounts does your client have? |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h3  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h2  | Caseworker Review |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Income result |
      | h2  | Income |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Declared cash income |
      | h2  | Dependants |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |
      | h3  | Bank statements |


