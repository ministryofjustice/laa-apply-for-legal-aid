module HMRC
  module ParsedResponse
    class Persistor
      def self.call(hmrc_response)
        new(hmrc_response).call
      end

      def initialize(hmrc_response)
        @hmrc_response = hmrc_response
        @application = hmrc_response.legal_aid_application
        @person = @hmrc_response.owner
      end

      def call
        return unless persistable?

        destroy_existing_employments if @person.employments.any?
        persist_response
      end

    private

      attr_reader :hmrc_response

      def persistable?
        Validator.call(hmrc_response, person: @hmrc_response.owner)
      end

      def destroy_existing_employments
        @person.employments.map(&:destroy!)
        @person.reload
      end

      def persist_response
        return if no_employments_in_response?

        create_employments
        create_employment_payments
        @application.save!
      end

      def no_employments_in_response?
        employments_array.nil?
      end

      def create_employments
        employments_array.each_with_index do |_emp, i|
          @application.employments << ::Employment.new(name: "Job #{i + 1}", owner_id: @person.id, owner_type: @person.class)
        end
      end

      def create_employment_payments
        employment = @person.employments.order(:name).first
        income_array.each do |income_hash|
          employment.employment_payments << new_employment_payment(income_hash)
        end
      end

      def response
        @response ||= hmrc_response.response
      end

      def data_array
        @data_array ||= response["data"]
      end

      def paye_hash
        @paye_hash ||= data_array.find { |h| h.key?("income/paye/paye") }
      end

      def income_array
        @income_array ||= paye_hash.dig("income/paye/paye", "income")
      end

      def employments_hash
        @employments_hash ||= data_array.find { |h| h.key?("employments/paye/employments") }
      end

      def employments_array
        @employments_array ||= employments_hash&.fetch("employments/paye/employments")
      end

      def new_employment_payment(income_hash)
        ::EmploymentPayment.new(
          date: date_from_hash(income_hash),
          gross: gross_from_hash(income_hash),
          benefits_in_kind: 0,
          national_insurance: ni_from_hash(income_hash),
          tax: tax_from_hash(income_hash),
        )
      end

      def date_from_hash(hash)
        Date.parse hash.fetch("paymentDate")
      end

      def gross_from_hash(hash)
        hash.fetch("grossEarningsForNics").fetch("inPayPeriod1")
      end

      def tax_from_hash(hash)
        (hash["taxDeductedOrRefunded"] || 0.0) * -1
      end

      def ni_from_hash(hash)
        return 0.0 unless hash.key?("employeeNics")

        hash.fetch("employeeNics").fetch("inPayPeriod1") * -1
      end
    end
  end
end
