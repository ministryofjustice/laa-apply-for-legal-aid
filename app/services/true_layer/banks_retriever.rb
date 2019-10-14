module TrueLayer
  class BanksRetriever
    UnsuccessfulRetrievalError = Class.new(StandardError)

    API_URL_OPEN_BANKING = 'https://auth.truelayer.com/api/providers/oauth/openbanking'.freeze
    API_URL_OAUTH = 'https://auth.truelayer.com/api/providers/oauth'.freeze

    def self.banks
      new.banks
    end

    def banks
      all_banks.sort_by { |bank| bank[:display_name] }
    end

    private

    def all_banks
      fetch(API_URL_OPEN_BANKING) + fetch(API_URL_OAUTH)
    end

    def fetch(url)
      response = Net::HTTP.get_response(URI.parse(url))
      return raise_error(response) unless response.is_a?(Net::HTTPOK)

      JSON.parse(response.body, symbolize_names: true)
    end

    def raise_error(response)
      raise UnsuccessfulRetrievalError, "Retrieval Failed: #{response.message} (#{response.code}) #{response.body}"
    end
  end
end
