class BankTransaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :transaction_type, optional: true

  enum operation: {
    credit: 'credit'.freeze,
    debit: 'debit'.freeze
  }
end
