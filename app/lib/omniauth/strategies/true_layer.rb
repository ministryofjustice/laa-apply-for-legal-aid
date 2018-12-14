# This strategy modifies the behaviour of OmniAuth so that it can be used to manage
# Oauth2 authentication via TrueLayer.
# Note that you need to restart the server to apply changes to this file.
require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class TrueLayer < OmniAuth::Strategies::OAuth2
      option :name, :true_layer

      option :client_options,
             site: 'https://auth.truelayer.com',
             authorize_url: 'https://auth.truelayer.com/',
             token_url: 'https://auth.truelayer.com/connect/token'

      def authorize_params
        super.merge(enable_mock: enable_mock)
      end

      def token_params
        redirect_uri = URI(callback_url)
        redirect_uri.query = nil
        super.merge(
          redirect_uri: redirect_uri.to_s
        )
      end

      def enable_mock
        env_setting = ENV['TRUE_LAYER_ENABLE_MOCK']
        return false if env_setting.blank?

        ActiveModel::Type::Boolean.new.cast(env_setting)
      end
    end
  end
end
