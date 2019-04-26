module CCMS
  class ReferenceDataParser < BaseParser
    TRANSACTION_ID_PATH = '//Body//ReferenceDataInqRS//HeaderRS//TransactionID'.freeze
    RESULTS_PATH = '//Body//ReferenceDataInqRS//Results'.freeze

    def parse
      raise 'Invalid transaction request id' if extracted_transaction_request_id != @transaction_request_id

      extracted_reference_id
    end

    private

    def extracted_transaction_request_id
      @doc.xpath(TRANSACTION_ID_PATH).text
    end

    def extracted_reference_id
      @doc.xpath(RESULTS_PATH).text
    end
  end
end
