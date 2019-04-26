module CCMS
  class BaseParser
    def initialize(tx_request_id, response)
      @transaction_request_id = tx_request_id
      @response = response
      @doc = Nokogiri::XML(@response)
      @doc.remove_namespaces!
    end
  end
end
