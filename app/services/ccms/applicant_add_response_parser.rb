module CCMS
  class ApplicantAddResponseParser < BaseResponseParser
    TRANSACTION_ID_PATH = '//Body//ClientAddRS//HeaderRS//TransactionID'.freeze
    STATUS_PATH = '//Body//ClientAddRS//HeaderRS//Status//Status'.freeze

    def parse
      raise 'Invalid transaction request id' if extracted_transaction_request_id != @transaction_request_id

      extracted_status
    end

    private

    def extracted_transaction_request_id
      @doc.xpath(TRANSACTION_ID_PATH).text
    end

    def extracted_status
      @doc.xpath(STATUS_PATH).text
    end
  end
end
