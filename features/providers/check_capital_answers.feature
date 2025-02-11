@javascript
Feature: Check capital income answers

  Scenario: For a non-passported, bank statement upload journey
    Given I have completed the income and capital sections of a non-passported application with bank statement uploads
    When I am viewing the means capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Your client's property |
      | h3  | Vehicles |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h2  | Your client's accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | One-off payments your client received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Employment income |
      | h3  | Payments your client gets |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client gets in cash |
      | h3  | Payments your client pays in cash |
      | h2  | Payments from scheme or charities |

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

  Scenario: For a non-passported truelayer bank transactions journey
    Given I have completed the income and capital sections of a non-passported application with open banking transactions
    When I am viewing the means capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Your client's property |
      | h3  | Vehicles |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | One-off payments your client received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Employment income |
      | h3  | Payments your client gets |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client gets in cash |
      | h3  | Payments your client pays in cash    |
      | h2  | Payments from scheme or charities |

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

  Scenario: For a passported journey
    Given I have completed the capital sections of passported application
    When I am viewing the passported capital check your answers page

    Then the following sections should exist:
      | tag | section |
      | h1  | Check your answers |
      | h2  | Your client's capital |
      | h3  | Property |
      | h3  | Your client's property |
      | h3  | Vehicles |
      | h2  | Vehicle 1 |
      | h2  | Bank accounts |
      | h3  | Your client's accounts |
      | h2  | Which savings or investments does your client have? |
      | h2  | Which assets does your client have? |
      | h2  | Restrictions on your client's assets |
      | h2  | One-off payments your client received |
      | h2  | Disregarded payment 1 |
      | h2  | Payment to be reviewed 1 |
      | h3  | What happens next |

    Then the following sections should not exist:
      | tag | section |
      | h2  | Your client's income |
      | h3  | Employment income |
      | h3  | Payments your client gets |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client pays |
      | h3  | Payments your client gets in cash |
      | h3  | Payments your client pays in cash    |
      | h2  | Payments from scheme or charities |

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
