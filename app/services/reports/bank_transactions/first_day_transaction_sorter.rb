module Reports
  module BankTransactions
    class FirstDayTransactionSorter < BaseTransactionSorter
      # This class is responsible for sorting the array of transactions for the first day (where there
      # is no running_balance from the previous day) into the correct sequence so that the running_balance plus the amount on the
      # following transaction equals the running_balance on the following transaction.
      #
      def self.call(transactions)
        new(transactions).call
      end

      def initialize(transactions)
        super()
        @txn_array = transactions
        @txn_hash = @txn_array.index_by(&:id)
      end

      def call
        return @txn_array if @txn_array.size == 1

        return @txn_array if no_running_balances?

        @txn_array.each do |txn|
          find_subsequent_transaction(txn)
        end
        ordered_results
      end

      private

      def find_matching_balance(txn)
        @txn_array.detect { |item| item.id != txn.id && item.running_balance == txn.running_balance + item.amount }
      end

      def find_subsequent_transaction(txn)
        # find the transaction that has a running_balance that equals this running_balance + amount
        # and assign its id to this transactions next_tx_id
        #
        matching_txn = find_matching_balance(txn)
        return if matching_txn.nil?

        @txn_hash[txn.id].next_txn_id = matching_txn.id
        @txn_hash[matching_txn.id].previous_txn_id = txn.id
      end

      def ordered_results
        # starting at the transaction with no previous_txn_id, sequece them according to
        # the next_txn_id until we reach a transaction with no next_txn_id
        #
        results = []
        transaction = @txn_hash.values.detect { |txn| txn.previous_txn_id.nil? }
        results << transaction
        while transaction.next_txn_id.present?
          transaction = @txn_hash[transaction.next_txn_id]
          results << transaction
        end
        check_all_transactions_in_sequence(results)
      end
    end
  end
end
