module TrueLayer
  class ApiClient
    TRUE_LAYER_URL = 'https://api.truelayer.com'.freeze

    def initialize(token)
      @token = token
    end

    def provider
      perform_lookup('/data/v1/me').first
    end

    def account_holders
      perform_lookup('/data/v1/info')
    end

    def accounts
      perform_lookup('/data/v1/accounts')
    end

    def transactions(account_id, date_from, date_to)
      params = {
        from: date_from.utc.iso8601,
        to: date_to.utc.iso8601
      }
      perform_lookup("/data/v1/accounts/#{account_id}/transactions?#{params.to_query}")
    end

    def account_balance(account_id)
      perform_lookup("/data/v1/accounts/#{account_id}/balance").first
    end

    private

    attr_reader :token

    def perform_lookup(path)
      response = connection.get(path)

      if response.success?
        JSON.parse(response.body).deep_symbolize_keys[:results]
      else
        # TODO: implement better logic in dealing with errors
        # some errors are inevitable (like "Feature not supported by the provider")
        # while others need to be addressed

        Rails.logger.warn("TrueLayer Error : #{response.body}")
        []
      end
    end

    def connection
      @connection ||= Faraday.new(url: TRUE_LAYER_URL) do |conn|
        conn.authorization :Bearer, token
        conn.response :logger if Rails.env.development?
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
