@javascript
Feature: Means report

  Scenario: For a non-passported, non-TrueLayer application when the client is employed
    Given I have completed a non-passported employed application with bank statement uploads
    When I view the means report

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Proceeding eligibility |
      | h2  | Passported means |
      | h2  | Income result |
      | h2  | Income |
      | h3  | Employment income |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Caseworker Review |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h3  | Bank statements |

    Then the following sections should not exist:
      | tag | section |
      | h3  | Your client's accounts |
      | h3  | Client's bank accounts |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Employed income result |
      | h2  | Declared cash income |
      | h2  | Dependants |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |

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
      | Variation or discharge under section 5 protection from harassment act 1997 |

    And the Income result questions should exist:
      | question |
      | Total gross income assessed |
      | Total disposable income assessed |
      | Gross income limit |
      | Disposable income lower limit |
      | Disposable income upper limit |
      | Income contribution |

    And the Income questions and answers should match:
      | question | answer |
      | Gross employment income | £2,143.97 |
      | Income tax | -£204.15 |
      | National insurance | -£161.64 |
      | Fixed employment deduction | -£45 |
      | Benefits | £75 |
      | Financial help from friends or family | £0 |
      | Maintenance payments | £0 |
      | Income from property or lodger | £0 |
      | Student loan or grant | £0 |
      | Pension | £0 |

    And I should see "Total income"

    And the Employment notes questions should exist:
      | Do you need to tell us anything else about your client's employment? |
      | Details |

    And the Outgoings questions and answers should match:
      | question | answer |
      | Housing payments (any declared housing benefits have been deducted from this total) | £125 |
      | Childcare payments | £0 |
      | Maintenance payments to a former partner | £0 |
      | Payments towards legal aid in a criminal case | £0 |

    And I should see "Total outgoings"

    And the Deductions questions should exist:
      | question |
      | Dependants allowance |
      | Total deductions |

    And the Deductions questions should not exist:
      | question |
      | Income from benefits excluded from calculation |

    And the Caseworker review section should contain:
      | question | answer |
      | Caseworker review required? | Yes |
      | Review reasons | Bank statements uploaded |
      | Review reasons | Non-Passported application |

    And the Capital result questions should exist:
      | question |
      | Total capital assessed |
      | Capital lower limit |
      | Capital upper limit |
      | Capital contribution |

    And the Property question should exist:
      | question |
      | Does your client own the home that they live in? |

    And the Property details questions should exist:
      | question |
      | How much is the home they live in worth? |
      | How much is left to pay on the mortgage? |
      | Does your client own the home with anyone else? |
      | What percentage of the home does your client legally own? |

    And the Vehicle ownership question should exist:
      | question |
      | Does your client own a vehicle? |

    And the Vehicles questions should exist:
      | What is the estimated value of the vehicle? |
      | Are there any payments left on the vehicle? |
      | The vehicle was bought more than three years ago? |
      | Is the vehicle in regular use? |

    And the "Bank accounts", for static bank account totals, questions should exist:
      | question |
      | Current accounts |
      | Savings accounts |

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
      | Timeshare property |
      | Land |
      | Any valuable items worth £500 or more |
      | Money or assets from the estate of a person who has died |
      | Money owed to them, including from a private mortgage |
      | Interest in a trust |
      | Second property or holiday home estimated value |
      | Second property or holiday home outstanding mortgage amount |
      | Second property or holiday home percentage owned |

    And the "Restrictions on your client's assets" questions should exist:
      | question |
      | Is your client banned from selling or borrowing against their assets? |
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
      | h3  | Employment income |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Caseworker Review |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h2  | Property, savings and other assets |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h3  | Client's bank accounts |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Employed income result |
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
      | Variation or discharge under section 5 protection from harassment act 1997 |

    And the Income result questions should exist:
      | question |
      | Total gross income assessed |
      | Total disposable income assessed |
      | Gross income limit |
      | Disposable income lower limit |
      | Disposable income upper limit |
      | Income contribution |

    And the Income questions and answers should match:
      | question | answer |
      | Gross employment income | £2,143.97 |
      | Income tax | -£204.15 |
      | National insurance | -£161.64 |
      | Fixed employment deduction | -£45 |
      | Benefits | £75 |
      | Financial help from friends or family | £0 |
      | Maintenance payments | £0 |
      | Income from property or lodger | £0 |
      | Student loan or grant | £0 |
      | Pension | £0 |

    And I should see "Total income"

    And the Employment notes questions should exist:
      | Do you need to tell us anything else about your client's employment? |
      | Details |

    And the Outgoings questions and answers should match:
      | question | answer |
      | Housing payments | £125 |
      | Childcare payments | £0 |
      | Maintenance payments to a former partner | £0 |
      | Payments towards legal aid in a criminal case | £0 |

    And I should see "Total outgoings"

    And the Deductions questions should exist:
      | question |
      | Dependants allowance |
      | Income from benefits excluded from calculation |
      | Total deductions |

    And the Caseworker review questions should exist:
      | question |
      | Caseworker review required? |
      | Review reasons |

    And the Caseworker review section should contain:
      | question | answer |
      | Caseworker review required? | Yes |
      | Review reasons | Non-Passported application |

    And the Capital result questions should exist:
      | question |
      | Total capital assessed |
      | Capital lower limit |
      | Capital upper limit |
      | Capital contribution |

    And the Property question should exist:
      | question |
      | Does your client own the home that they live in? |

    And the Property details questions should exist:
      | question |
      | How much is the home they live in worth? |
      | How much is left to pay on the mortgage? |
      |Does your client own the home with anyone else? |
      | What percentage of the home does your client legally own? |

    And the Vehicle ownership question should exist:
      | question |
      | Does your client own a vehicle? |

    And the Vehicles questions should exist:
      | What is the estimated value of the vehicle? |
      | Are there any payments left on the vehicle? |
      | The vehicle was bought more than three years ago? |
      | Is the vehicle in regular use? |

    And the "Bank accounts", for open banking accounts, questions should exist:
      | question |
      | Current accounts |
      | Savings accounts |

    And the "Bank accounts", for open banking accounts, questions and answers table should exist:
      | question | answer |
      | Account Name,12345678,000000 | 75.57 |
      | Second Account,87654321,999999 | 57.57 |

    And the "Your client's accounts" questions should exist:
      | question |
      | Has savings accounts they cannot access online |
      | Amount in offline savings accounts |

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
      | Timeshare property |
      | Land |
      | Any valuable items worth £500 or more |
      | Money or assets from the estate of a person who has died |
      | Money owed to them, including from a private mortgage |
      | Interest in a trust |
      | Second property or holiday home estimated value |
      | Second property or holiday home outstanding mortgage amount |
      | Second property or holiday home percentage owned |

    And the "Restrictions on your client's assets" questions should exist:
      | question |
      | Is your client banned from selling or borrowing against their assets? |
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
      | h2  | Bank accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h2  | Caseworker Review |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Income result |
      | h2  | Income |
      | h2  | Employed income result |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Declared cash income |
      | h2  | Dependants |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |
      | h3  | Bank statements |

  Scenario: For a non means tested journey
    Given I have completed a non means tested application
    When I view the means report

    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Proceeding eligibility |
      | h2  | Passported means |
      | h2  | Income result |
      | h2  | Income |
      | h3  | Employment income |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Caseworker Review |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | Payments from scheme or charities |
      | h3  | Bank statements |
      | h3  | Your client's accounts|

   And the "Client details" check your answers section should contain:
    | question | answer |
    | Age at computation date | 17 years old |
    | Was the client means-tested? | No |
