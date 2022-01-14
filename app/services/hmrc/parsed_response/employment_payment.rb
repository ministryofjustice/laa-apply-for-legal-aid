module HMRC
  module ParsedResponse
    class EmploymentPayment
      def initialize(payment_hash)
        @payment_hash = payment_hash
      end

      def payment_date
        Date.parse @payment_hash.fetch('paymentDate')
      end

      def formatted_payment_date
        payment_date.strftime('%F')
      end

      def gross_pay
        @payment_hash.fetch('grossEarningsForNics').fetch('inPayPeriod1')
      end

      def tax
        (@payment_hash['taxDeductedOrRefunded'] || 0.0) * -1
      end

      def national_insurance
        return 0.0 unless @payment_hash.key?('employeeNics')

        @payment_hash.fetch('employeeNics').fetch('inPayPeriod1') * -1
      end

      def benefits_in_kind
        0.0
      end

      def net_pay
        (gross_pay + benefits_in_kind + tax + national_insurance).round(2)
      end
    end
  end
end
