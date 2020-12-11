module CashTransactions
  class Outgoing < ::CashTransaction
    validate :transaction_type_is_debit

    def transaction_type_is_debit
      errors.add(:transaction_type, 'must be debit') if transaction_type&.operation != 'debit'
    end
  end
end
