class BankTransaction < ApplicationRecord
  belongs_to :bank_account

  enum operation: {
    credit: 'credit',
    debit: 'debit'
  }
end
