module HMRC
  class OAuth
    HMRC_API_HOST = 'https://test-api.service.hmrc.gov.uk'.freeze
    HMRC_API_OAUTH = '/oauth/token'.freeze

    def initialize; end

    def call
      Faraday.new(url: HMRC_API_HOST) do |connection|
        connection.headers['Authorization'] = "Bearer #{bearer_token}"
        connection.headers['Accept'] = accept
        connection.adapter Faraday.default_adapter
      end
    end

    def bearer_token(force_reset: false)
      reset_bearer_token if force_reset
      @bearer_token ||= JSON.parse(Faraday.post(oauth_path, oauth_payload, oauth_headers).body)['access_token']
    end

    private

    def reset_bearer_token
      @bearer_token = nil
    end

    def oauth_path
      HMRC_API_HOST + HMRC_API_OAUTH
    end

    def oauth_payload
      {
        'client_secret' => ENV['HMRC_CLIENT_SECRET'],
        'client_id' => ENV['HMRC_CLIENT_ID'],
        'grant_type' => 'client_credentials'
      }
    end

    def oauth_headers
      { 'content-type' => 'application/x-www-form-urlencoded' }
    end

    # override these method in the derived class if youe need more/different headers
    def hmrc_api_path
      nil
    end

    def accept
      'application/json'
    end
  end
end
