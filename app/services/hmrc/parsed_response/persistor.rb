module HMRC
  module ParsedResponse
    class Persistor
      def self.call(application)
        new(application).call
      end

      def initialize(application)
        @application = application
      end

      def call
        destroy_existing_employments if @application.employments.any?
        persist_response
      end

    private

      def destroy_existing_employments
        @application.employments.map(&:destroy!)
        @application.reload
      end

      def persist_response
        return if no_hmrc_response? || no_data_in_hmrc_response?

        create_employments
        create_employment_payments
        @application.save!
      end

      def no_hmrc_response?
        hmrc_response.nil?
      end

      def no_data_in_hmrc_response?
        employments_array.nil?
      end

      def create_employments
        employments_array.each_with_index do |_emp, i|
          @application.employments << ::Employment.new(name: "Job #{i + 1}")
        end
      end

      def create_employment_payments
        employment = @application.employments.order(:name).first
        income_array.each do |income_hash|
          employment.employment_payments << new_employment_payment(income_hash)
        end
      end

      def hmrc_response
        @hmrc_response ||= Response.use_case_one_for(@application.id).response
      end

      def data_array
        @data_array ||= hmrc_response['data']
      end

      def paye_hash
        @paye_hash ||= data_array.detect { |hash| hash.key?('income/paye/paye') }
      end

      def employments_array
        @employments_array ||= data_array.detect { |hash| hash.key?('employments/paye/employments') }['employments/paye/employments']
      end

      def income_array
        @income_array ||= paye_hash.dig('income/paye/paye', 'income')
      end

      def new_employment_payment(income_hash)
        ::EmploymentPayment.new(
          date: date_from_hash(income_hash),
          gross: gross_from_hash(income_hash),
          benefits_in_kind: 0,
          national_insurance: ni_from_hash(income_hash),
          tax: tax_from_hash(income_hash)
        )
      end

      def date_from_hash(hash)
        Date.parse hash.fetch('paymentDate')
      end

      def gross_from_hash(hash)
        hash.fetch('grossEarningsForNics').fetch('inPayPeriod1')
      end

      def tax_from_hash(hash)
        (hash['taxDeductedOrRefunded'] || 0.0) * -1
      end

      def ni_from_hash(hash)
        return 0.0 unless hash.key?('employeeNics')

        hash.fetch('employeeNics').fetch('inPayPeriod1') * -1
      end
    end
  end
end
