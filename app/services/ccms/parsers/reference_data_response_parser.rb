module CCMS
  module Parsers
    class ReferenceDataResponseParser < BaseResponseParser
      TRANSACTION_ID_PATH = "//Body//ReferenceDataInqRS//HeaderRS//TransactionID".freeze
      RESULTS_PATH = "//Body//ReferenceDataInqRS//Results".freeze

      def reference_id
        @reference_id ||= parse(:extracted_reference_id)
        check_case_ccms_reference
      end

      def response_type
        "ReferenceDataInqRS".freeze
      end

    private

      def extracted_transaction_request_id
        text_from(TRANSACTION_ID_PATH)
      end

      def extracted_reference_id
        text_from(RESULTS_PATH)
      end

      def check_case_ccms_reference
        return @reference_id if @reference_id != "ERROR"

        raise CCMSError, "case_ccms_reference returned as ERROR"
      end
    end
  end
end
