module CCMS
  module Parsers
    class ReferenceDataResponseParser < BaseResponseParser
      TRANSACTION_ID_PATH = '//Body//ReferenceDataInqRS//HeaderRS//TransactionID'.freeze
      RESULTS_PATH = '//Body//ReferenceDataInqRS//Results'.freeze

      def reference_id
        @reference_id ||= parse(:extracted_reference_id)
      end

      def response_type
        'ReferenceDataInqRS'.freeze
      end

      private

      def extracted_transaction_request_id
        text_from(TRANSACTION_ID_PATH)
      end

      def extracted_reference_id
        text_from(RESULTS_PATH)
      end
    end
  end
end
