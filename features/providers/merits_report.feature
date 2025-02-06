Feature: Merits report

  @javascript @vcr
  Scenario: Checking merits report for a domestic abuse application with multiple proceedings
    Given I complete the journey as far as check merits answers with multiple proceedings with delegated functions
    When I view the merits report

    Then I should see "Apply service case reference:"
    And I should see "CCMS case reference:"

    And the following sections should exist:
      | tag | section |
      | h1  | Merits report |
      | h2  | Client details |
      | h2  | Previous Legal Aid |
      | h2  | What you're applying for |
      | h2  | Delegated functions |
      | h3  | Inherent jurisdiction high court injunction |
      | h3  | Non-molestation order |
      | h3  | Child arrangements order (residence) |
      | h2  | Case details |
      | h3  | Opponents |
      | h3  | Mental capacity |
      | h3  | Domestic abuse summary |
      | h3  | Children involved in this application |
      | h3  | Why the matter is opposed |
      | h3  | Allegation |
      | h3  | Section 8 and LASPO |
      | h3  | Offer of undertakings |
      | h3  | Statement of case |
      | h2  | Supporting evidence |
      | h3  | Files to support the application |

    And the Client questions and answers should match:
      | question | answer |
      | First name | .+ |
      | Last name | .+ |
      | Has your client ever changed their last name? | No |
      | What was your client's last name at birth? | Same as last name |
      | Date of birth | \d{1,2} [JFMASOND].* \d{4} |
      | Age at computation date | \d{1,2} years old |
      | Was the client means-tested? | Yes |
      | National Insurance number | [A-Z]{2} \d{2} \d{2} \d{2} [A-Z]{1} |
      | Client has a partner? | No |

    And the Previous Legal Aid questions and answers should match:
      | question | answer |
      | Has your client applied for civil legal aid before? | No |
      | Previous CCMS reference number | - |

    And the What you're applying for questions and answers should match:
      | question | answer |
      | Proceeding 1 | Inherent jurisdiction high court injunction |
      | Proceeding 2 | Non-molestation order |
      | Proceeding 3 | Child arrangements order (residence) |

    And I can see "Not used" within "#app-check-your-answers__delegated_functions__inherent_jurisdiction_high_court_injunction"

    And the "app-check-your-answers__delegated_functions__nonmolestation_order" questions and answers should match:
      | question | answer |
      | Date report | \d{1,2} [JFMASOND].* \d{4}  |
      | Date delegated functions were used | \d{1,2} [JFMASOND].+ \d{4}  |
      | Days to report | \d{1,2} days |

     And the Emergency cost limit questions and answers should match:
      | question | answer |
      | Higher cost limit requested | No |

     And the Opponents questions and answers should match:
      | question | answer |
      | Opponent 1 name | .+ |
      | Opponent 1 type | Individual |

     And the Mental capacity questions and answers should match:
      | question | answer |
      | All parties can understand terms of a court order? | No |
      | Why you think the court would enforce a breach of an order | .+ |

     And the Domestic abuse summary questions and answers should match:
      | question | answer |
      | Why a warning letter has not been sent | .+ |
      | Police action taken | details of police notification or not |
      | Bail conditions | .+ |

     And the Children involved in this application questions and answers should match:
      | question | answer |
      | Child 1 name | .+ |
      | Child 1 date of birth | \d{1,2} [JFMASOND].+ \d{4} |
      | Child 2 name | .+ |
      | Child 2 date of birth | \d{1,2} [JFMASOND].+ \d{4} |
      | Child 3 name | .+ |
      | Child 3 date of birth | \d{1,2} [JFMASOND].+ \d{4} |

    And the Why the matter is opposed questions and answers should match:
      | question | answer |
      | Reasons why the matter is opposed | .+ |

    And the Allegation questions and answers should match:
      | question | answer |
      | Client wholly or substantially denies any allegations? | Yes |

    And the Section 8 and LASPO questions and answers should match:
      | question | answer |
      | Section 8 proceedings are in scope of LASPO? | No |

    And the Offer of undertakings questions and answers should match:
      | question | answer |
      | Undertakings offered | .* |

    And the Statement of case questions and answers should match:
      | question | answer |
      | File names | Fake file name 1 (15.7 KB) |
      | Statement | Statement of case text entered here |
