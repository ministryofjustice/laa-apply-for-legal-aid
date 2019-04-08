module CCMS
  class ReferenceDataParser
    TRANSACTION_ID_PATH = '//Body//ReferenceDataInqRS//HeaderRS//TransactionID'.freeze
    RESULTS_PATH = '//Body//ReferenceDataInqRS//Results'.freeze

    def initialize(tx_request_id, response)
      @transaction_request_id = tx_request_id
      @response = response
      @doc = Nokogiri::XML(@response)
      @doc.remove_namespaces!
    end

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
