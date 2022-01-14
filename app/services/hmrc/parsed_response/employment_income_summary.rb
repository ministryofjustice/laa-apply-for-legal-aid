module HMRC
  module ParsedResponse
    # Utility class to parse the HMRC response record and present in a fashion that will be easy to
    # iterate through and display on the page
    #
    # Usage:
    #
    # summary = EmploymentIncomeSummary.new(legal_aid_application_id)
    # summary.employments.each do |employment|
    #   employment.payments.each do |payment|
    #     puts payment.payment_date
    #     puts payment.gross_pay
    #     puts payment.tax
    #     puts payment.national_insurance
    #   end
    # end
    #
    class EmploymentIncomeSummary
      attr_reader :employments

      def initialize(legal_aid_application_id)
        @legal_aid_application_id = legal_aid_application_id
        @employments = []
        parse_response
      end

      def num_employments
        @employments.size
      end

      private

      def parse_response
        data_array = hmrc_response['data']
        paye_hash = data_array.detect { |hash| hash.key?('income/paye/paye') }
        income_array = paye_hash.dig('income/paye/paye', 'income')

        @employments << Employment.new(income_array)
      end

      def hmrc_response
        @hmrc_response ||= Response.use_case_one_for(@legal_aid_application_id).response
      end
    end
  end
end
