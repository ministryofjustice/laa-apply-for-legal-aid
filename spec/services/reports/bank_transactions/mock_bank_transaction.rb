module Reports
  module BankTransactions
    class MockBankTransaction
      attr_reader :id, :amount
      attr_accessor :previous_txn_id, :next_txn_id, :running_balance

      def initialize(amount, balance)
        @id = SecureRandom.uuid
        @amount = BigDecimal(amount.to_s)
        @running_balance = BigDecimal(balance.to_s) unless balance.nil?
        @previous_txn_id = nil
        @next_txn_id = nil
      end
    end
  end
end
