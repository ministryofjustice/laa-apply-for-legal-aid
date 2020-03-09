module CCMS
  module Parsers
    class ApplicantSearchResponseParser < BaseResponseParser
      TRANSACTION_ID_PATH = '//Body//ClientInqRS//HeaderRS//TransactionID'.freeze
      RECORD_COUNT_PATH = '//Body//ClientInqRS//RecordCount//RecordsFetched'.freeze
      APPLICANT_CCMS_REFERENCE_PATH = '//Body//ClientInqRS//Client//ClientReferenceNumber'.freeze

      def record_count
        @record_count ||= parse(:extracted_record_count)
      end

      def applicant_ccms_reference
        @applicant_ccms_reference ||= parse(:extracted_applicant_ccms_reference)
      end

      private

      def response_type
        'ClientInqRS'.freeze
      end

      def extracted_transaction_request_id
        text_from(TRANSACTION_ID_PATH)
      end

      def extracted_record_count
        text_from(RECORD_COUNT_PATH)
      end

      def extracted_applicant_ccms_reference
        doc.xpath(APPLICANT_CCMS_REFERENCE_PATH).first&.text
      end
    end
  end
end
