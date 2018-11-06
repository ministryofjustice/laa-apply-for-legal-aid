module TrueLayer
  class IdentifyApplicant
    TRUE_LAYER_URL = 'https://api.truelayer.com'.freeze

    attr_reader :token, :error

    def initialize(token)
      @token = token
    end

    def applicant
      return login_error unless response.success?
      Applicant.find_by(email: emails) || applicant_lookup_error
    end

    def emails
      user_data[:emails]
    end

    def user_data
      results[:results].first
    end

    def results
      JSON.parse(response.body).deep_symbolize_keys
    end

    def response
      @response ||= conn.get '/data/v1/info'.freeze
    end

    def conn
      @conn ||= Faraday.new(url: TRUE_LAYER_URL) do |conn|
        conn.authorization :Bearer, token
        conn.response :logger if Rails.env.development?
        conn.adapter Faraday.default_adapter
      end
    end

    def applicant_lookup_error
      error_and_return_nil 'Credentials do not match'.freeze
    end

    def login_error
      error_and_return_nil 'TrueLayer log in failed'.freeze
    end

    def error_and_return_nil(message)
      @error = message
      nil
    end
  end
end
