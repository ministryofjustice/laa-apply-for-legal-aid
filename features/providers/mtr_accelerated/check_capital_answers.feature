@javascript
Feature: Check capital income answers
# TODO: AP-5493 - these tests can be moved to the `feaures/providers/` folder once mtra switched on and stable
# They can provide a basis for a feature test suite for excercisng the various check your answer pages and flows
#

  Scenario: For a non-passported, bank statement upload journey
    Given the feature flag for means_test_review_a is enabled
    And the MTR-A start date is in the past
    And I have completed the income and capital sections of a non-passported application with bank statement uploads post-MTRA
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
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h3  | Payments your client receives in cash |
      | h3  | Payments your client makes in cash |
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
    Given the feature flag for means_test_review_a is enabled
    And the MTR-A start date is in the past
    And I have completed the income and capital sections of a non-passported application with open banking transactions post-MTRA
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
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h3  | Payments your client receives in cash |
      | h3  | Payments your client makes in cash    |
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
    Given the feature flag for means_test_review_a is enabled
    And the MTR-A start date is in the past
    And I have completed the capital sections of passported application post-MTRA
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
      | h3  | Client employment income |
      | h3  | Payments your client receives |
      | h3  | Student finance |
      | h2  | Your client's outgoings |
      | h3  | Payments your client makes |
      | h3  | Payments your client receives in cash |
      | h3  | Payments your client makes in cash    |
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
