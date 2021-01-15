class CashTransaction < ApplicationRecord
  # The CashTranscation records the monthly amount paid or received by an applicant in cash for a particular month
  # for a particular TransactionType.  These records always come in threes, representing each of the last three months
  # before an application was made.  The transaction date is set to the first of the month.

  belongs_to :legal_aid_application
  belongs_to :transaction_type

  validates_inclusion_of :month_number, in: [1, 2, 3]
end
