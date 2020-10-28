module Reports
  module BankTransactions
    class SubsequentDayTransactionSorter < BaseTransactionSorter
      # This class is responsible for sorting the array of transactions for all days except the first day
      #
      def self.call(balance, transactions)
        new(balance, transactions).call
      end

      def initialize(balance, transactions)
        super()
        @balance = balance
        @txn_array = transactions
      end

      def call
        # if the balance is nil, then the balances couldn't be computed on a previous day
        # so don't do anything.
        return @txn_array if @balance.nil?

        return sanitized_single_transaction if @txn_array.size == 1

        return @txn_array if no_running_balances?

        ordered_transactions
      end

      private

      def ordered_transactions
        results = []
        unordered_transactions = @txn_array.dup
        while unordered_transactions.any?
          txn = find_next_transaction(unordered_transactions)
          break if txn.nil?

          results << txn
          @balance = txn.running_balance
          unordered_transactions.delete(txn)
        end
        return results unless txn.nil?

        # if tx is nil, it means we aren't able to compute the balances
        set_transaction_running_balances_to_nil
        @txn_array
      end

      def find_next_transaction(unordered_transactions)
        unordered_transactions.detect { |txn| txn.running_balance == @balance + txn.amount }
      end

      def sanitized_single_transaction
        txn = @txn_array.first
        return @txn_array if @balance.nil?
        return @txn_array if txn.running_balance.nil?
        return @txn_array if @balance + txn.amount == txn.running_balance

        @txn_array.first.running_balance = nil
        @txn_array
      end
    end
  end
end
