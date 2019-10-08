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
        extra_params = { enable_mock: enable_mock }

        extra_params[:provider_id] = session[:provider_id] if session[:provider_id].present?
        extra_params[:consent_id] = consent_id if consent_id

        super.merge(extra_params)
      end

      def token_params
        redirect_uri = URI(callback_url)
        redirect_uri.query = nil
        super.merge(
          redirect_uri: redirect_uri.to_s
        )
      end

      def enable_mock
        Rails.configuration.x.true_layer.enable_mock
      end

      # If consent_id is set, the flow will skip TrueLayer's consent page.
      # consent_id is used by TrueLayer for tracking purposes and needs to be a static string specific to our TrueLayer account.
      # It could be something different than true_layer.client_id but it makes sense to use this value
      def consent_id
        Rails.configuration.x.true_layer.client_id
      end
    end
  end
end
