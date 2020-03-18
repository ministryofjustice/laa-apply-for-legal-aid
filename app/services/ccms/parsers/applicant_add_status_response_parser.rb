module CCMS
  module Parsers
    class ApplicantAddStatusResponseParser < BaseResponseParser
      TRANSACTION_REQUEST_ID_PATH = '//Body//ClientAddUpdtStatusRS//HeaderRS//RequestDetails//TransactionRequestID'.freeze
      STATUS_FREE_TEXT_PATH = '//Body//ClientAddUpdtStatusRS//HeaderRS//Status//StatusFreeText'.freeze
      APPLICANT_CCMS_REFERENCE_PATH = '//Body//ClientAddUpdtStatusRS//ClientReferenceNumber'.freeze

      def success?
        parse(:extracted_status_free_text) == 'Party Successfully Created.'
      end

      def applicant_ccms_reference
        @applicant_ccms_reference ||= parse(:extracted_applicant_ccms_reference)
      end

      private

      def response_type
        'ClientAddUpdtStatusRS'.freeze
      end

      def extracted_transaction_request_id
        text_from(TRANSACTION_REQUEST_ID_PATH)
      end

      def extracted_status_free_text
        text_from(STATUS_FREE_TEXT_PATH)
      end

      def extracted_applicant_ccms_reference
        text_from(APPLICANT_CCMS_REFERENCE_PATH)
      end
    end
  end
end
