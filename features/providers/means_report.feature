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
      | h2  | Outgoings and deductions |
      | h2  | Dependants |
      | h2  | Caseworker Review |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h3  | Your client's property |
      | h2  | Vehicles |
      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h3  | Your client's savings or investments |
      | h3  | Your client's assets |
      | h3  | Restrictions on your client's assets |
      | h2  | Capital disregards |
      | h3  | Bank statements |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Employed income result |
      | h2  | Declared cash income |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |
      | h2  | Payments from scheme or charities |

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

    And the Passported means question and answer should match:
      | question | answer |
      | In receipt of passporting benefit | No |

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
      | Total income | |

    And the 'Client' employment notes questions should exist:
      | Do you need to tell us anything else about your client's employment? |
      | Details for client |

    And the Outgoings and deductions questions and answers should match:
      | question | answer |
      | Client housing payments (any declared housing benefits have been deducted from this total) | £125 |
      | Client childcare payments | £0 |
      | Client maintenance payments to a former partner | £0 |
      | Client payments towards legal aid in a criminal case | £100 |
      | Dependants allowance | £0 |
      | Total outgoings and deductions | £225 |

    And the Dependants questions should exist:
      | question |
      | Client has dependants? |

    And the Dependants detail questions should exist:
      | Name |
      | Date of birth	|
      | What is their relationship to your client? |

    And the Caseworker review section should contain:
      | question | answer |
      | Caseworker review required? | Yes |
      | Review reasons | Review why some capital assets cannot be used towards legal aid |
      | Review reasons | Check the mandatory or discretionary capital disregards received by the client and decide if they should be included in the calculation  |
      | Review reasons | Non-Passported application |
      | Review reasons | Review report and uploaded evidence for the client's further employment information, provided in addition to data returned by HMRC |
      | Review reasons | Check uploaded bank statements for the client's account details. Open banking was not used |

    And the Capital result questions should exist:
      | question |
      | Total capital assessed |
      | Capital lower limit |
      | Capital upper limit |
      | Capital contribution |

    And the Property question should exist:
      | question |
      | Client owns the home they usually live in? |

    And the Property details questions should exist:
      | question |
      | Worth of the home they usually live in |
      | Amount left to pay on the mortgage |
      | The home is owned with someone else? |
      | Percentage of the home legally owned by the client |

    And the Vehicle ownership question should exist:
      | question |
      | Client owns a vehicle? |

    And the Vehicles questions should exist:
      | Worth of the vehicle |
      | Amount left to pay |
      | Vehicle was bought over 3 years ago? |
      | Vehicle is in regular use? |

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
      | Client is banned from selling or borrowing against assets? |
      | Details of restrictions |

    And the Capital disregards questions and answers should match:
      | question | answer |
      | Mandatory disregards | Budgeting Advances\n£1,001 on 8 August 2024\nHeld in Halifax |
      | Discretionary disregards | Compensation, damages or ex-gratia payments for personal harm\nFor: life changing injuries\n£1,002 on 8 August 2024\nHeld in Halifax |

    And the client Bank statements questions and answers should match:
      | question | answer |
      | Uploaded bank statements | original_filename.pdf (15.7 KB) |

    And I should not see any change links

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
      | h2  | Outgoings and deductions |
      | h2  | Dependants |
      | h2  | Caseworker Review |
      | h2  | Capital result |
      | h2  | Property, savings and other assets |
      | h3  | Property |
      | h2  | Vehicles |
      | h3  | Vehicles owned |
      | h3  | Vehicle 1 |
      | h2  | Bank accounts |
      | h3  | Your client's offline accounts |
      | h2  | Savings and assets |
      | h3  | Your client's savings or investments |
      | h3  | Your client's assets |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Employed income result |
      | h2  | Declared cash income |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |
      | h2  | Payments from scheme or charities |
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

    And the Passported means question and answer should match:
      | question | answer |
      | In receipt of passporting benefit | No |

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
      | Total income | |

    And the 'Client' employment notes questions should exist:
      | Do you need to tell us anything else about your client's employment? |
      | Details for client |

    And the Outgoings and deductions questions and answers should match:
      | question | answer |
      | Client housing payments (any declared housing benefits have been deducted from this total) | £125 |
      | Client childcare payments | £0 |
      | Client maintenance payments to a former partner | £0 |
      | Client payments towards legal aid in a criminal case | £100 |
      | Dependants allowance | £0 |
      | Total outgoings and deductions | £225 |

    And the Dependants questions should exist:
      | question |
      | Client has dependants? |

    And the Dependants detail questions should exist:
      | Name |
      | Date of birth	|
      | What is their relationship to your client? |

    And the Caseworker review section should contain:
      | question | answer |
      | Caseworker review required? | Yes |
      | Review reasons | Review why some capital assets cannot be used towards legal aid |
      | Review reasons | Check the mandatory or discretionary capital disregards received by the client and decide if they should be included in the calculation  |
      | Review reasons | Non-Passported application |
      | Review reasons | Review report and uploaded evidence for the client's further employment information, provided in addition to data returned by HMRC |

    And the Capital result questions should exist:
      | question |
      | Total capital assessed |
      | Capital lower limit |
      | Capital upper limit |
      | Capital contribution |

    And the Property question should exist:
      | question |
      | Client owns the home they usually live in? |

    And the Property details questions should exist:
      | question |
      | Worth of the home they usually live in |
      | Amount left to pay on the mortgage |
      | The home is owned with someone else? |
      | Percentage of the home legally owned by the client |

    And the Vehicle ownership question should exist:
      | question |
      | Client owns a vehicle? |

    And the Vehicles questions should exist:
      | Worth of the vehicle |
      | Amount left to pay |
      | Vehicle was bought over 3 years ago? |
      | Vehicle is in regular use? |

    And the "Bank accounts", for open banking accounts, questions should exist:
      | question |
      | Current accounts |
      | Savings accounts |

    And the "Bank accounts", for open banking accounts, questions and answers table should exist:
      | question | answer |
      | Account Name, 12345678, 000000 | £75.57 |
      | Second Account, 87654321, 999999 | £57.57 |

    And the "Your client's accounts" questions should exist:
      | question |
      | Has savings accounts they cannot access online? |
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
      | Client is banned from selling or borrowing against assets? |
      | Details of restrictions |

    And the Capital disregards questions and answers should match:
      | question | answer |
      | Mandatory disregards | Budgeting Advances\n£1,001 on 8 August 2024\nHeld in Halifax |
      | Discretionary disregards | Compensation, damages or ex-gratia payments for personal harm\nFor: life changing injuries\n£1,002 on 8 August 2024\nHeld in Halifax |

    And I should not see any change links

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
      | h2  | Capital disregards |
      | h2  | Caseworker Review |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Income result |
      | h2  | Income |
      | h2  | Employed income result |
      | h2  | Outgoings and deductions |
      | h2  | Declared income categories |
      | h2  | Student finance |
      | h2  | Declared cash income |
      | h2  | Dependants |
      | h2  | Declared outgoings categories |
      | h2  | Declared cash outgoings |
      | h2  | Payments from scheme or charities |
      | h3  | Bank statements |

    And the Passported means question and answer should match:
      | question | answer |
      | In receipt of passporting benefit | Yes |

    And I should not see any change links

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
      | h2  | One-off payments your client received |
      | h2  | Capital disregards |
      | h3  | Bank statements |
      | h3  | Your client's accounts|

    And the "Client details" check your answers section should contain:
      | question | answer |
      | Age at computation date | 17 years old |
      | Was the client means-tested? | No |

    And I should not see any change links
