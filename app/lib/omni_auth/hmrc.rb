module OmniAuth
  module HMRC
    class Client
      def initialize
        oauth_client
      end

      def oauth_client
        @oauth_client ||= ::OAuth2::Client.new(
          Rails.configuration.x.hmrc_interface.client_id,
          Rails.configuration.x.hmrc_interface.client_secret,
          site: Rails.configuration.x.hmrc_interface.host,
        )
      end

      def bearer_token
        Rails.configuration.x.hmrc_interface.test_mode? ? fake_bearer_token : access_token.token
      end

      def access_token
        @access_token = new_access_token if @access_token.nil? || @access_token.expired?
        @access_token
      end

    private

      def new_access_token
        oauth_client.client_credentials.get_token(scopes: "use_case_one,use_case_two")
      end

      def fake_bearer_token
        "fake-hmrc-interface-bearer-token"
      end
    end
  end
end
