module CCMS
  module Parsers
    class DocumentIdResponseParser < BaseResponseParser
      DOCUMENT_ID_PATH = '//Body//DocumentUploadRS//DocumentID'.freeze

      def document_id
        @document_id ||= parse(:extracted_document_id)
      end

      private

      def response_type
        'DocumentUploadRS'.freeze
      end

      def expect_transaction_request_id_in_response?
        false
      end

      def extracted_document_id
        text_from(DOCUMENT_ID_PATH)
      end
    end
  end
end
