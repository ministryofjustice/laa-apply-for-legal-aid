module CCMS
  class DocumentIdResponseParser < BaseResponseParser
    TRANSACTION_ID_PATH = '//Body//DocumentUploadRS//HeaderRS//TransactionID'.freeze
    DOCUMENT_ID_PATH = '//Body//DocumentUploadRS//DocumentID'.freeze

    def document_id
      @document_id ||= parse(:extracted_document_id)
    end

    private

    def extracted_transaction_request_id
      text_from(TRANSACTION_ID_PATH)
    end

    def extracted_document_id
      text_from(DOCUMENT_ID_PATH)
    end
  end
end
