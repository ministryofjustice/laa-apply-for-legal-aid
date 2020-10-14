module Reports
  module BankTransactions
    class BaseTransactionSorter
      private

      def no_running_balances?
        running_balance_classes = @txn_array.map { |txn| txn.running_balance.class }.uniq
        return true if running_balance_classes  == [NilClass]

        return false if running_balance_classes == [BigDecimal]

        msg = "Not all bank transactions have running_balances: ids: #{@txn_array.map(&:id).join(', ')}"
        Raven.capture_exception(OrderingError.new(msg))
        set_transaction_running_balances_to_nil
        true
      end

      def check_all_transactions_in_sequence(ordered_transactions)
        # if the number of transactions in ordered_transactions isn't the same as @txn_array, that
        # means the running_balances didn't compute and a sequence couldn't be found.  Set all running_balances to nil
        # and capture a message to sentry
        return ordered_transactions if ordered_transactions.size == @txn_array.size

        Raven.capture_exception(OrderingError.new("No sequence could be found for bank transactions with ids: #{@txn_array.map(&:id)}"))
        set_transaction_running_balances_to_nil
        @txn_array
      end

      def set_transaction_running_balances_to_nil
        @txn_array.each { |txn| txn.running_balance = nil }
      end
    end
  end
end
