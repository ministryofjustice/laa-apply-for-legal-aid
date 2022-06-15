module HMRC
  module ParsedResponse
    class Validator
      attr_accessor :errors

      Error = Struct.new(:attribute, :message)

      def self.call(hmrc_response, applicant:)
        new(hmrc_response, applicant:).call
      end

      def initialize(hmrc_response, applicant:)
        @hmrc_response = hmrc_response
        @response = hmrc_response.response
        @applicant = applicant
        @errors = []
      end

      def call
        validate_use_case
        validate_response
        validate_response_data
        validate_response_income
        validate_response_individual
        validate_response_employments

        capture_errors unless errors_ignoreable?
        errors.empty?
      end

    private

      attr_reader :hmrc_response, :response, :applicant

      def validate_use_case
        errors << error(:use_case, "use_case must be \"one\", but was \"#{hmrc_response.use_case}\"") if hmrc_response.use_case != "one"
      end

      def validate_response
        errors << error(:response, "response must be present") unless response
        errors << error(:response, "response status must be \"completed\"") if response&.dig("status") != "completed"
        errors << error(:response, "response submission must be present") if response&.dig("submission").blank?
      end

      def validate_response_data
        errors << error(:data, "data must be an array") unless data.is_a?(Array)
      end

      def validate_response_income
        errors << error(:income, "income must be an array") unless income.is_a?(Array)

        errors << error(:income, "inPayPeriod1 must be numeric") if income&.any? do |payment|
          !payment&.dig("grossEarningsForNics")&.dig("inPayPeriod1").is_a?(Numeric)
        end

        errors << error(:income, "paymentDate must be a valid iso8601 formatted date") if income&.any? do |payment|
          !valid_iso8601_date?(payment&.dig("paymentDate"))
        end
      end

      def validate_response_individual
        errors << error(:individual, "individual must match applicant") unless individual &&
          applicant &&
          applicant.national_insurance_number.casecmp?(individual["nino"]) &&
          applicant.date_of_birth.iso8601 == individual["dateOfBirth"]
      end

      def validate_response_employments
        errors << error(:employments, "employments must be present") unless employments && employments.present?
      end

      def data
        @data ||= response&.dig("data")
      end

      def paye
        @paye ||= data&.find { |hash| hash["income/paye/paye"] }
      end

      def income
        @income ||= paye&.dig("income/paye/paye", "income")
      end

      def individual
        @individual ||= data&.find { |hash| hash["individuals/matching/individual"] }&.dig("individuals/matching/individual")
      end

      def employments
        @employments ||= data&.find { |hash| hash["employments/paye/employments"] }&.dig("employments/paye/employments")
      end

      def valid_iso8601_date?(date)
        Date.iso8601(date)
      rescue Date::Error
        false
      end

      def error(*args)
        Error.new(*args)
      end

      def capture_errors
        AlertManager.capture_message("HMRC Response is unacceptable (id: #{hmrc_response.id}) - #{errors.map(&:message).join(', ')}")
      end

      def client_details_not_found
        { "error" => "submitted client details could not be found in HMRC service" }
      end

      def no_employments_found
        errors == [error(:employments, "employments must be present")]
      end

      def errors_ignoreable?
        errors.empty? || errors.map(&:attribute).include?(:use_case) || data&.include?(client_details_not_found) || no_employments_found
      end
    end
  end
end
