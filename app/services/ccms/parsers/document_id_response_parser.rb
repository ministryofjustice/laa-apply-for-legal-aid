module CCMS
  module Parsers
    class DocumentIdResponseParser < BaseResponseParser
      DOCUMENT_ID_PATH = '//Body//DocumentUploadRS//DocumentID'.freeze

      def document_id
        @document_id ||= parse(:extracted_document_id)
      end

      def parse(data_method)
        __send__(data_method)
      end

      private

      def extracted_document_id
        text_from(DOCUMENT_ID_PATH)
      end
    end
  end
end
