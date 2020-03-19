module CCMS
  module Parsers
    class DocumentUploadResponseParser < BaseResponseParser
      STATUS_PATH = '//Body//DocumentUploadRS//HeaderRS//Status'.freeze
      TRANSACTION_ID_PATH = '//Body/DocumentUploadRS/TransactionID'.freeze

      def success?
        /Success/.match?(parse(:extracted_status))
      end

      private

      def status_path
        "/Envelope/Body/#{response_type}/HeaderRS/Status"
      end

      def expect_transaction_request_id_in_response?
        false
      end

      def response_type
        'DocumentUploadRS'.freeze
      end

      def extracted_status
        text_from(STATUS_PATH)
      end
    end
  end
end
