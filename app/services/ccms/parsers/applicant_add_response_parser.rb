module CCMS
  module Parsers
    class ApplicantAddResponseParser < BaseResponseParser
      TRANSACTION_ID_PATH = '//Body//ClientAddRS//HeaderRS//TransactionID'.freeze
      STATUS_PATH = '//Body//ClientAddRS//HeaderRS//Status//Status'.freeze

      def success?
        parse(:extracted_status) == 'Success'
      end

      private

      def response_type
        'ClientAddRS'.freeze
      end

      def extracted_transaction_request_id
        text_from(TRANSACTION_ID_PATH)
      end

      def extracted_status
        text_from(STATUS_PATH)
      end
    end
  end
end
