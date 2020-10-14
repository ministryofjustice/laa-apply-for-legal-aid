module Reports
  module BankTransactions
    class BankTransactionSorter
      attr_reader :legal_aid_application

      delegate :bank_accounts, to: :applicant
      delegate :applicant, to: :legal_aid_application

      def self.call(legal_aid_application)
        new(legal_aid_application).call
      end

      def initialize(legal_aid_application)
        @legal_aid_application = legal_aid_application
        @transactions = []
      end

      def call
        bank_accounts.order(:name).each { |bank_account| sort_transactions(bank_account) }
        @transactions
      end

      private

      def sort_transactions(bank_account)
        @first_day = true
        grouped_transactions = bank_account.bank_transactions.group_by(&:happened_at)
        grouped_transactions.keys.sort.each { |date| add_ordered_transactions(grouped_transactions[date]) }
      end

      def add_ordered_transactions(txns)
        @first_day ? order_transactions_for_first_day(txns) : order_transactions_for_subsequent_days(txns)
      end

      def order_transactions_for_first_day(txns)
        ordered_transactions = FirstDayTransactionSorter.call(txns)
        @first_day = false
        @transactions += ordered_transactions
        @running_balance = @transactions.last.running_balance
      end

      def order_transactions_for_subsequent_days(txns)
        ordered_transactions = SubsequentDayTransactionSorter.call(@running_balance, txns)
        @transactions += ordered_transactions
        @running_balance = @transactions.last.running_balance
      end
    end
  end
end
