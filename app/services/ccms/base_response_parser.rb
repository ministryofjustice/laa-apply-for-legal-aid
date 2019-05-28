module CCMS
  class BaseResponseParser
    attr_reader :transaction_request_id, :response

    def initialize(tx_request_id, response)
      @transaction_request_id = tx_request_id
      @response = response
    end

    def doc
      @doc ||= Nokogiri::XML(response).remove_namespaces!
    end

    def parse(data_method)
      raise CcmsError, 'Invalid transaction request id' unless extracted_id_matches_request_id?

      __send__(data_method)
    end

    def extracted_id_matches_request_id?
      extracted_transaction_request_id == @transaction_request_id
    end

    def text_from(xpath)
      doc.xpath(xpath).text
    end
  end
end
