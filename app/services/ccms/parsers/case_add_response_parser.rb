module CCMS
  module Parsers
    class CaseAddResponseParser < BaseResponseParser
      TRANSACTION_REQUEST_ID_PATH = '//CaseAddRS//HeaderRS//RequestDetails//TransactionRequestID'.freeze
      STATUS_PATH = '//CaseAddRS//HeaderRS//Status//Status'.freeze

      def success?
        parse(:extracted_status) == 'Success'
      end

      private

      def response_type
        'CaseAddRS'.freeze
      end

      def extracted_transaction_request_id
        text_from(TRANSACTION_REQUEST_ID_PATH)
      end

      def extracted_status
        text_from(STATUS_PATH)
      end
    end
  end
end
