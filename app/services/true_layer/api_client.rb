module TrueLayer
  class ApiClient
    ApiError = Class.new(StandardError)
    TRUE_LAYER_URL = "https://api.truelayer.com".freeze

    def initialize(token)
      @token = token
    end

    def provider
      perform_lookup("/data/v1/me")
    end

    def account_holders
      perform_lookup("/data/v1/info")
    end

    def accounts
      perform_lookup("/data/v1/accounts")
    end

    def transactions(account_id, date_from, date_to)
      params = date_params(date_from, date_to)
      perform_lookup("/data/v1/accounts/#{account_id}/transactions?#{params.to_query}")
    end

    def date_params(date_from, date_to)
      {
        from: date_from.utc.iso8601,
        to: date_to.utc.iso8601,
      }
    end

    def account_balance(account_id)
      perform_lookup("/data/v1/accounts/#{account_id}/balance")
    end

  private

    attr_reader :token

    def perform_lookup(path)
      response = connection.get(path)
      parsed_response = parsed_response(response)

      raise ApiError, "{\"TrueLayerError\" : #{response.body}}" unless response.success?

      SimpleResult.new(value: parsed_response.deep_symbolize_keys[:results])
    rescue JSON::ParserError, Faraday::ConnectionFailed, ApiError => e
      simple_error(e)
    end

    def parsed_response(response)
      JSON.parse(response.body)
    end

    def simple_error(error)
      AlertManager.capture_exception(error)
      SimpleResult.new(error:)
    end

    def connection
      @connection ||= Faraday.new(url: TRUE_LAYER_URL) do |conn|
        conn.request :authorization, "Bearer", token
        conn.response :logger if Rails.configuration.x.logs_faraday_response
        conn.adapter Faraday.default_adapter
      end
    end
  end
end
