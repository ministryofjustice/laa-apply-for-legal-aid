module CCMS
  class ClientSearchParser
    TRANSACTION_ID_PATH = '//Body//ClientInqRS//HeaderRS//TransactionID'.freeze
    RECORD_COUNT_PATH = '//Body//ClientInqRS//RecordCount//RecordsFetched'.freeze

    def initialize(tx_request_id, response)
      @transaction_request_id = tx_request_id
      @response = response
      @doc = Nokogiri::XML(@response)
      @doc.remove_namespaces!
    end

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
