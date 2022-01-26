module HMRC
  module ParsedResponse
    class Employment
      attr_reader :payments

      def initialize(hmrc_income_array)
        @payments = hmrc_income_array.map { |payment_hash| EmploymentPayment.new(payment_hash) }
        sort_payments_most_recent_first
      end

      private

      def sort_payments_most_recent_first
        @payments.sort! { |a, b| b.payment_date <=> a.payment_date }
      end
    end
  end
end
