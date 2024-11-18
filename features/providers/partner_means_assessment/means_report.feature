@javascript
Feature: Means report when partner is present

  Scenario: For a non-passported, non-TrueLayer application when the client is employed
    Given I have completed a non-passported employed with partner application with bank statement uploads
    When I view the means report
    Then the following sections should exist:
      | tag | section |
      | h2  | Client details |
      | h2  | Proceeding eligibility |
      | h2  | Passported means |
      | h2  | Income result |
      | h2  | Income |
      | h3  | Client employment income |
      | h2  | Outgoings |
      | h2  | Deductions |
      | h2  | Caseworker Review |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Vehicles |
      | h2  | Bank accounts |
      | h2  | Which savings or investments does either your client or their partner have? |
      | h2  | Which assets does either your client or their partner have? |
      | h2  | Restrictions on your client's or their partner's assets |
      | h2  | Your client's and the partner's payments from schemes or charities |
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
      | Client gross employment income | £2,143.97 |
      | Client income tax | -£204.15 |
      | Client national insurance | -£161.64 |
      | Client fixed employment deduction | -£45 |
      | Client benefits, charitable or government payments | £75 |
      | Client financial help from friends or family | £0 |
      | Client maintenance payments | £0 |
      | Client income from property or lodger | £0 |
      | Client student loan or grant | £0 |
      | Client pension | £0 |
      | Partner gross employment income | £2,229.17 |
      | Partner income tax | -£235.20 |
      | Partner national insurance | -£171.86 |
      | Partner fixed employment deduction | -£45 |
      | Partner benefits, charitable or government payments | £86.67 |
      | Partner financial help from friends or family | £166.67 |
      | Partner maintenance payments | £21 |
      | Partner income from property or lodger | £200 |
      | Partner student loan or grant | £100 |
      | Partner pension | £30 |
      | Total income | | 

    And the 'Client' employment notes questions should exist:
      | Do you need to tell us anything else about your client's employment? |
      | Details for client |
    And the 'Partner' employment notes questions should exist:
      | Do you need to tell us anything else about the partner's employment? |
      | Details for client |

    And the Outgoings questions and answers should match:
      | question | answer |
      | Client housing payments (any declared housing benefits have been deducted from this total) | £125 |
      | Client childcare payments | £0 |
      | Client maintenance payments to a former partner | £0 |
      | Client payments towards legal aid in a criminal case | £100 |
      | Partner housing payments (any declared housing benefits have been deducted from this total) | £400 |
      | Partner childcare payments | £30 |
      | Partner maintenance payments to a former partner | £50 |
      | Partner payments towards legal aid in a criminal case | £0 |
      | Total outgoings | £705 |

    And the Deductions questions should exist:
      | question |
      | Dependants allowance |
      | Total deductions |

    And the Dependants questions should exist:
      | question |
      | Does your client or their partner have any dependants? |

    And the Dependants detail questions should exist:
      | Name |
      | Date of birth	|
      | What is their relationship to your client or their partner? |

    And the Caseworker review section should contain:
      | question | answer |
      | Caseworker review required? | Yes |
      | Review reasons | Client's bank statements uploaded |
      | Review reasons | Non-Passported application |

    And the Capital result questions should exist:
      | question |
      | Total capital assessed |
      | Capital lower limit |
      | Capital upper limit |
      | Capital contribution |

    And the Property question should exist:
      | question |
      | Does your client or their partner own the home that they live in? |

    And the Property details questions should exist:
      | question |
      | How much is the home your client and their partner live in worth? |
      | How much is left to pay on the mortgage? |
      | Does your client or their partner own the home with anyone else? |
      | What percentage of the home do your client and their partner legally own? |

    And the Vehicle ownership question should exist:
      | question |
      | Does your client or their partner own a vehicle? |

    And the Vehicles questions should exist:
      | What is the estimated value of the vehicle? |
      | Are there any payments left on the vehicle? |
      | The vehicle was bought more than three years ago? |
      | Is the vehicle in regular use? |

    And the 'Applicant' "Bank accounts", for static bank account totals, questions should exist:
      | question |
      | Client's current accounts |
      | Client's savings accounts |
    And the 'Partner' "Bank accounts", for static bank account totals, questions should exist:
      | question |
      | Partner's current accounts |
      | Partner's savings accounts |
    And the 'Joint' "Bank accounts", for static bank account totals, questions should exist:
      | question |
      | Joint current accounts |
      | Joint savings accounts |

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
      | Is your client or their partner banned from selling or borrowing against their assets? |
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
