module CCMS
  module Parsers
    class CaseAddStatusResponseParser < BaseResponseParser
      TRANSACTION_ID_PATH = '//Body//CaseAddUpdtStatusRS//HeaderRS//TransactionID'.freeze
      STATUS_FREE_TEXT_PATH = '//Body//CaseAddUpdtStatusRS//HeaderRS//Status//StatusFreeText'.freeze

      def success?
        parse(:extracted_status_free_text) == 'Case successfully created.'
      end

      private

      def response_type
        'CaseAddUpdtStatusRS'.freeze
      end

      def extracted_transaction_request_id
        text_from(TRANSACTION_ID_PATH)
      end

      def extracted_status_free_text
        text_from(STATUS_FREE_TEXT_PATH)
      end
    end
  end
end
