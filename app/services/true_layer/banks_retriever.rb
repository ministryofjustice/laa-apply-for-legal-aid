module TrueLayer
  class BanksRetriever
    UnsuccessfulRetrievalError = Class.new(StandardError)
    API_URL = 'https://auth.truelayer.com/api/providers/oauth/openbanking'.freeze

    def self.banks
      new.banks
    end

    def banks
      return raise_error unless response.is_a?(Net::HTTPOK)

      JSON.parse(response.body, symbolize_names: true)
    end

    private

    def response
      @response ||= Net::HTTP.get_response(uri)
    end

    def uri
      URI.parse(API_URL)
    end

    def raise_error
      raise UnsuccessfulRetrievalError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
    end
  end
end
