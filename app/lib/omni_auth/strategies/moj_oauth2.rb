require 'oauth2'
require 'omniauth'
require 'securerandom'
require 'socket'       # for SocketError
require 'timeout'      # for Timeout::Error

# rubocop:disable Lint/MissingSuper
# :nocov:

module OmniAuth
  module Strategies
    # Authentication strategy for connecting with APIs constructed using
    # the [OAuth 2.0 Specification](http://tools.ietf.org/html/draft-ietf-oauth-v2-10).
    # You must generally register your application with the provider and
    # utilize an application id and secret in order to authenticate using
    # OAuth 2.0.
    class MojOauth2 # rubocop:disable Metrics/ClassLength
      include OmniAuth::Strategy
      include Browser::ActionController

      def self.inherited(subclass)
        OmniAuth::Strategy.included(subclass)
      end

      args %i[client_id client_secret] # rubocop:disable Layout/SpaceBeforeBrackets

      option :client_id, nil
      option :client_secret, nil
      option :client_options, {}
      option :authorize_params, {}
      option :authorize_options, %i[scope state]
      option :token_params, {}
      option :token_options, []
      option :auth_token_params, {}
      option :provider_ignores_state, false
      option :pkce, false
      option :pkce_verifier, nil
      option :pkce_options, {
        code_challenge: proc { |verifier|
          Base64.urlsafe_encode64(
            Digest::SHA2.digest(verifier),
            padding: false
          )
        },
        code_challenge_method: 'S256'
      }

      attr_accessor :access_token

      def client
        ::OAuth2::Client.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      credentials do
        hash = { 'token' => access_token.token }
        hash['refresh_token'] = access_token.refresh_token if access_token.expires? && access_token.refresh_token
        hash['expires_at'] = access_token.expires_at if access_token.expires?
        hash['expires'] = access_token.expires?
        hash
      end

      def request_phase # rubocop:disable Metrics/AbcSize
        auth_params = authorize_params
        applicant_id = session['warden.user.applicant.key'].first.first

        # We save the session in the redis database here in case the user backgrounds his browser on a mobile
        # device while looking up the bank credentials, which would result in the session being destroyed.
        #
        # We save it under the applicant_id key AND the state key, because it will be required in two different places,
        # the callback phase of this class, where only the state will be available, and the gather_transactions_controller
        # where only the applicant_id will be available.
        #
        OauthSessionSaver.store(applicant_id, session)
        OauthSessionSaver.store(auth_params[:state], session)

        Debug.record_request(session, auth_params, callback_url, browser_details)
        redirect client.auth_code.authorize_url({ redirect_uri: callback_url }.merge(auth_params))
      end

      def authorize_params # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        options.authorize_params[:state] = SecureRandom.hex(24)

        if OmniAuth.config.test_mode
          @env ||= {}
          @env['rack.session'] ||= {}
        end

        params = options.authorize_params
                        .merge(options_for('authorize'))
                        .merge(pkce_authorize_params)

        session['omniauth.pkce.verifier'] = options.pkce_verifier if options.pkce
        session['omniauth.state'] = params[:state]

        params
      end

      def token_params
        options.token_params.merge(options_for('token')).merge(pkce_token_params)
      end

      def callback_phase # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        # we ALWAYS restore the session even if a perfectly good one exists because if we try to do it inside an
        # if statement, then the path that doesn't restore the session will set it to nil.  Go figure!
        #
        restored_session = OauthSessionSaver.get(state)
        restored_session.each { |k, v| session[k] = v }
        OauthSessionSaver.destroy!(state)

        error = request.params['error_reason'] || request.params['error']

        if error
          Debug.record_error(session, request.params, '', browser_details)
          fail!(error, CallbackError.new(request.params['error'], request.params['error_description'] || request.params['error_reason'], request.params['error_uri']))
        elsif !options.provider_ignores_state && (request.params['state'].to_s.empty? || request.params['state'] != session.delete('omniauth.state'))
          Debug.record_error(session, request.params, 'CSRF detected', browser_details)
          fail!(:csrf_detected, CallbackError.new(:csrf_detected, 'CSRF detected'))
        else
          self.access_token = build_access_token
          self.access_token = access_token.refresh! if access_token.expired?
          super
        end
      rescue ::OAuth2::Error, CallbackError => e
        fail!(:invalid_credentials, e)
      rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
        fail!(:timeout, e)
      rescue ::SocketError => e
        fail!(:failed_to_connect, e)
      end

      protected

      def pkce_authorize_params
        return {} unless options.pkce

        options.pkce_verifier = SecureRandom.hex(64)

        # NOTE: see https://tools.ietf.org/html/rfc7636#appendix-A
        {
          code_challenge: options.pkce_options[:code_challenge]
                                 .call(options.pkce_verifier),
          code_challenge_method: options.pkce_options[:code_challenge_method]
        }
      end

      def pkce_token_params
        return {} unless options.pkce

        { code_verifier: session.delete('omniauth.pkce.verifier') }
      end

      def build_access_token
        verifier = request.params['code']
        client.auth_code.get_token(verifier, { redirect_uri: callback_url }.merge(token_params.to_hash(symbolize_keys: true)), deep_symbolize(options.auth_token_params))
      end

      def deep_symbolize(options)
        options.each_with_object({}) do |(key, value), hash|
          hash[key.to_sym] = value.is_a?(Hash) ? deep_symbolize(value) : value
        end
      end

      def options_for(option) # rubocop:disable Metrics/AbcSize
        hash = {}
        options.send(:"#{option}_options").select { |key| options[key] }.each do |key|
          hash[key.to_sym] = if options[key].respond_to?(:call)
                               options[key].call(env)
                             else
                               options[key]
                             end
        end
        hash
      end

      private

      def state
        request.params['state']
      end

      def browser_details
        browser = Browser.new(
          request.env['HTTP_USER_AGENT'],
          accept_language: request.env['HTTP_ACCEPT_LANGUAGE']
        )
        "#{browser.platform.name}::#{browser.name}::#{browser.full_version}"
      end

      # An error that is indicated in the OAuth 2.0 callback.
      # This could be a `redirect_uri_mismatch` or other
      class CallbackError < StandardError
        attr_accessor :error, :error_reason, :error_uri

        def initialize(error, error_reason = nil, error_uri = nil)
          self.error = error
          self.error_reason = error_reason
          self.error_uri = error_uri
        end

        def message
          [error, error_reason, error_uri].compact.join(' | ')
        end
      end
    end
  end
end

OmniAuth.config.add_camelization 'oauth2', 'OAuth2'
# :nocov:
# rubocop:enable Lint/MissingSuper
