module CCMS
  class ClientSearchParser < BaseParser
    TRANSACTION_ID_PATH = '//Body//ClientInqRS//HeaderRS//TransactionID'.freeze
    RECORD_COUNT_PATH = '//Body//ClientInqRS//RecordCount//RecordsFetched'.freeze

    def parse
      raise 'Invalid transaction request id' if extracted_transaction_request_id != @transaction_request_id

      extracted_record_count
    end

    private

    def extracted_transaction_request_id
      @doc.xpath(TRANSACTION_ID_PATH).text
    end

    def extracted_record_count
      @doc.xpath(RECORD_COUNT_PATH).text
    end
  end
end
