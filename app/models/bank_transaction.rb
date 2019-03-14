class BankTransaction < ApplicationRecord
  belongs_to :bank_account
  belongs_to :transaction_type, optional: true

  scope :by_type, -> do
    includes(:transaction_type)
      .where.not(transaction_type_id: nil)
      .group_by(&:transaction_type)
  end

  enum operation: {
    credit: 'credit'.freeze,
    debit: 'debit'.freeze
  }
end
