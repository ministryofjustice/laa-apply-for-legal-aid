require_relative 'boot'

require "rails/all"
require 'sprockets/es6'

Bundler.require(*Rails.groups)

module LaaApplyForLegalAid
  class Application < Rails::Application
    config.load_defaults 5.2

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
    end

    # config.certificate = File.open(ENV['APP_CERT']).read
    # config.private_key = File.open(ENV['APP_SECERT']).read

    config.x.application.host             = ENV['HOST']
    config.x.benefit_check.service_name   = ENV['BC_LSC_SERVICE_NAME']
    config.x.benefit_check.client_org_id  = ENV['BC_CLIENT_ORG_ID']
    config.x.benefit_check.client_user_id = ENV['BC_CLIENT_USER_ID']
    config.x.benefit_check.wsdl_url       = ENV['BC_WSDL_URL']

    config.x.laa_portal.idp_slo_target_url             = ENV['LAA_PORTAL_IDP_SLO_TARGET_URL']
    config.x.laa_portal.idp_sso_target_url             = ENV['LAA_PORTAL_IDP_SSO_TARGET_URL']
    config.x.laa_portal.idp_cert                       = ENV['LAA_PORTAL_IDP_CERT']
    config.x.laa_portal.idp_cert_fingerprint_algorithm = ENV['LAA_PORTAL_IDP_CERT_FINGERPRINT_ALGORITHM']

    config.govuk_notify_templates = config_for(
      :govuk_notify_templates, env: ENV.fetch('GOVUK_NOTIFY_ENV', 'development')
    ).symbolize_keys
  end
end
