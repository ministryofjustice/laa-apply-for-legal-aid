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

    config.x.application.host             = ENV['HOST']
    config.x.benefit_check.service_name   = ENV['BC_LSC_SERVICE_NAME']
    config.x.benefit_check.client_org_id  = ENV['BC_CLIENT_ORG_ID']
    config.x.benefit_check.client_user_id = ENV['BC_CLIENT_USER_ID']
    config.x.benefit_check.wsdl_url       = ENV['BC_WSDL_URL']

    config.x.laa_portal.idp_slo_target_url             = ENV['LAA_PORTAL_IDP_SLO_TARGET_URL']
    config.x.laa_portal.idp_sso_target_url             = ENV['LAA_PORTAL_IDP_SSO_TARGET_URL']
    config.x.laa_portal.idp_cert                       = ENV['LAA_PORTAL_IDP_CERT']
    config.x.laa_portal.idp_cert_fingerprint_algorithm = ENV['LAA_PORTAL_IDP_CERT_FINGERPRINT_ALGORITHM']
    config.x.laa_portal.mock_saml = ENV['LAA_PORTAL_MOCK_SAML']

    config.x.laa_portal.certificate = ENV['LAA_PORTAL_CERTIFICATE']
    config.x.laa_portal.secret_key = ENV['LAA_PORTAL_SECRET_KEY']

    config.x.kubernetes_deployment = ENV['KUBERNETES_DEPLOYMENT'] == 'true'

    config.govuk_notify_templates = config_for(
      :govuk_notify_templates,
      env: ENV.fetch('GOVUK_NOTIFY_ENV', 'development')
    ).symbolize_keys
    config.x.support_email_address = 'apply-for-legal-aid@digital.justice.gov.uk'.freeze
    config.x.smoke_test_email_address = 'simulate-delivered@notifications.service.gov.uk'.freeze

    config.x.admin_portal.allow_reset = ENV['ADMIN_ALLOW_RESET'] == 'true'
    config.x.admin_portal.allow_create_test_applications = ENV['ADMIN_ALLOW_CREATE_TEST_APPLICATIONS'] == 'true'
    config.x.admin_portal.password = ENV['ADMIN_PASSWORD']

    config.x.metrics_service_host = ENV.fetch('METRICS_SERVICE_HOST', 'localhost')

    require Rails.root.join 'app/lib/govuk_elements_form_builder/form_builder'
    ActionView::Base.default_form_builder = GovukElementsFormBuilder::FormBuilder

    config.active_job.queue_adapter = :sidekiq
  end
end
