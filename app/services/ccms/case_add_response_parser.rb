module CCMS
  class CaseAddResponseParser < BaseResponseParser
    TRANSACTION_ID_PATH = '//CaseAddRS//HeaderRS//TransactionID'.freeze
    STATUS_PATH = '//CaseAddRS//HeaderRS//Status//Status'.freeze

    def success?
      parse(:extracted_status) == 'Success'
    end

    private

    def extracted_transaction_request_id
      text_from(TRANSACTION_ID_PATH)
    end

    def extracted_status
      text_from(STATUS_PATH)
    end
  end
end
