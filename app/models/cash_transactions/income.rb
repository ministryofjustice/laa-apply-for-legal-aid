module CashTransactions
  class Income < ::CashTransaction
    validate :transaction_type_is_credit

    def transaction_type_is_credit
      errors.add(:transaction_type, 'must be credit') if transaction_type&.operation != 'credit'
    end
  end
end
