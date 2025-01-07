@javascript
Feature: Check capital income answers

  Scenario: For a non-passported client only, bank statement upload journey
    Given I have completed the income and capital sections of a non-passported application with bank statement uploads
    When I am viewing the means capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's capital |
      | h2  | Property |
      | h2  | Your client's property |
      | h2  | Vehicles |
      | h2  | Vehicles owned |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h2  | Your client's accounts |
      | h2  | Savings and assets |
      | h2  | Your client's savings or investments |
      | h2  | Your client's assets |
      | h2  | One-off payments your client received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client and their partner's capital |
      | h2  | Your client and their partner's property |
      | h2  | The partner's accounts |
      | h2  | Your client or their partner's savings or investments |
      | h2  | Your client or their partner's assets |
      | h2  | Restrictions on your client or their partner's assets |
      | h2  | One-off payments your client or their partner received |

    And the Disregarded payment 1 questions and answers should match:
      | question | answer |
      | Payment type | Budgeting Advances |
      | Amount and date received | £1,001 on 8 August 2024 |
      | Bank account | Halifax |

    And the Payment to be reviewed 1 questions and answers should match:
      | question | answer |
      | Payment type | Compensation, damages or ex-gratia payments for personal harm |
      | What the payment is for | life changing injuries |
      | Amount and date received | £1,002 on 8 August 2024 |
      | Bank account | Halifax |

  Scenario: For a non-passported client only, truelayer bank transactions journey
    Given I have completed the income and capital sections of a non-passported application with open banking transactions
    When I am viewing the means capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's capital |
      | h2  | Property |
      | h2  | Your client's property |
      | h2  | Vehicles |
      | h2  | Vehicles owned |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h2  | Your client's accounts |
      | h2  | Savings and assets |
      | h2  | Your client's savings or investments |
      | h2  | Your client's assets |
      | h2  | One-off payments your client received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client and their partner's capital |
      | h2  | Your client and their partner's property |
      | h2  | The partner's accounts |
      | h2  | Your client or their partner's savings or investments |
      | h2  | Your client or their partner's assets |
      | h2  | Restrictions on your client or their partner's assets |
      | h2  | One-off payments your client or their partner received |

    And the Disregarded payment 1 questions and answers should match:
      | question | answer |
      | Payment type | Budgeting Advances |
      | Amount and date received | £1,001 on 8 August 2024 |
      | Bank account | Halifax |

    And the Payment to be reviewed 1 questions and answers should match:
      | question | answer |
      | Payment type | Compensation, damages or ex-gratia payments for personal harm |
      | What the payment is for | life changing injuries |
      | Amount and date received | £1,002 on 8 August 2024 |
      | Bank account | Halifax |

  Scenario: For a passported client only journey
    Given I have completed the capital sections of passported application
    When I am viewing the passported capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's capital |
      | h2  | Property |
      | h2  | Your client's property |
      | h2  | Vehicles |
      | h2  | Vehicles owned |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h2  | Your client's accounts |
      | h2  | Savings and assets |
      | h2  | Your client's savings or investments |
      | h2  | Your client's assets |
      | h2  | One-off payments your client received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client and their partner's capital |
      | h2  | Your client and their partner's property |
      | h2  | The partner's accounts |
      | h2  | Your client or their partner's savings or investments |
      | h2  | Your client or their partner's assets |
      | h2  | Restrictions on your client or their partner's assets |
      | h2  | One-off payments your client or their partner received |

    And the Disregarded payment 1 questions and answers should match:
      | question | answer |
      | Payment type | Budgeting Advances |
      | Amount and date received | £1,001 on 8 August 2024 |
      | Bank account | Halifax |

    And the Payment to be reviewed 1 questions and answers should match:
      | question | answer |
      | Payment type | Compensation, damages or ex-gratia payments for personal harm |
      | What the payment is for | life changing injuries |
      | Amount and date received | £1,002 on 8 August 2024 |
      | Bank account | Halifax |

  Scenario: For a non-passported client and their partner, bank statement upload journey
    Given I have completed the income and capital sections of a non-passported application with bank statement uploads
    When I am viewing the means capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client and their partner's capital |
      | h2  | Property |
      | h2  | Your client and their partner's property |
      | h2  | Vehicles |
      | h2  | Vehicles owned |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h2  | Your client's accounts |
      | h2  | The partner's accounts |
      | h2  | Joint accounts |
      | h2  | Savings and assets |
      | h2  | Your client or their partner's savings or investments |
      | h2  | Your client or their partner's assets |
      | h2  | Restrictions on your client or their partner's assets |
      | h2  | One-off payments your client or their partner received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's capital |
      | h2  | Your client's property |
      | h2  | Your client's savings or investments |
      | h2  | Your client's assets |
      | h2  | One-off payments your client received |

    And the Disregarded payment 1 questions and answers should match:
      | question | answer |
      | Payment type | Budgeting Advances |
      | Amount and date received | £1,001 on 8 August 2024 |
      | Bank account | Halifax |

    And the Payment to be reviewed 1 questions and answers should match:
      | question | answer |
      | Payment type | Compensation, damages or ex-gratia payments for personal harm |
      | What the payment is for | life changing injuries |
      | Amount and date received | £1,002 on 8 August 2024 |
      | Bank account | Halifax |

  Scenario: For a non-passported client and their partner, truelayer bank transactions journey
    Given I have completed the income and capital sections of a non-passported application with open banking transactions
    When I am viewing the means capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client and their partner's capital |
      | h2  | Property |
      | h2  | Your client and their partner's property |
      | h2  | Vehicles |
      | h2  | Vehicles owned |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h2  | Your client's accounts |
      | h2  | The partner's accounts |
      | h2  | Savings and assets |
      | h2  | Your client or their partner's savings or investments |
      | h2  | Your client or their partner's assets |
      | h2  | Restrictions on your client or their partner's assets |
      | h2  | One-off payments your client or their partner received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's capital |
      | h2  | Your client's property |
      | h2  | Your client's savings or investments |
      | h2  | Your client's assets |
      | h2  | One-off payments your client received |

    # TODO: Add this later on
    # And the Your client's bank accounts summary list questions should exist:
    #   | question |
    #   | Has savings accounts they cannot access online |
    #   | Amount in offline savings accounts |

    And the Disregarded payment 1 questions and answers should match:
      | question | answer |
      | Payment type | Budgeting Advances |
      | Amount and date received | £1,001 on 8 August 2024 |
      | Bank account | Halifax |

    And the Payment to be reviewed 1 questions and answers should match:
      | question | answer |
      | Payment type | Compensation, damages or ex-gratia payments for personal harm |
      | What the payment is for | life changing injuries |
      | Amount and date received | £1,002 on 8 August 2024 |
      | Bank account | Halifax |

  Scenario: For a passported client and their partner journey
    Given I have completed the capital sections of passported application
    When I am viewing the passported capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client and their partner's capital |
      | h2  | Property |
      | h2  | Your client and their partner's property |
      | h2  | Vehicles |
      | h2  | Vehicles owned |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h2  | Your client's accounts |
      | h2  | The partner's accounts |
      | h2  | Savings and assets |
      | h2  | Your client or their partner's savings or investments |
      | h2  | Your client or their partner's assets |
      | h2  | Restrictions on your client or their partner's assets |
      | h2  | One-off payments your client or their partner received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's capital |
      | h2  | Your client's property |
      | h2  | Your client's savings or investments |
      | h2  | Your client's assets |
      | h2  | One-off payments your client received |

    And the Disregarded payment 1 questions and answers should match:
      | question | answer |
      | Payment type | Budgeting Advances |
      | Amount and date received | £1,001 on 8 August 2024 |
      | Bank account | Halifax |

    And the Payment to be reviewed 1 questions and answers should match:
      | question | answer |
      | Payment type | Compensation, damages or ex-gratia payments for personal harm |
      | What the payment is for | life changing injuries |
      | Amount and date received | £1,002 on 8 August 2024 |
      | Bank account | Halifax |
