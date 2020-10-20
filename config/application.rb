require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module LaaApplyForLegalAid
  class Application < Rails::Application
    config.load_defaults '6.0'
    config.action_mailer.delivery_job = 'ActionMailer::MailDeliveryJob'
    # zeitwerk autoloader is causing errors so use classic
    config.autoloader = :classic

    config.time_zone = 'London'

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
    end

    config.x.application.host             = ENV['HOST']
    config.x.benefit_check.service_name   = ENV['BC_LSC_SERVICE_NAME']
    config.x.benefit_check.client_org_id  = ENV['BC_CLIENT_ORG_ID']
    config.x.benefit_check.client_user_id = ENV['BC_CLIENT_USER_ID']
    config.x.benefit_check.wsdl_url       = ENV['BC_WSDL_URL']

    config.x.ccms_soa.submit_applications_to_ccms = ENV['CCMS_SOA_SUBMIT_APPLICATIONS'] == 'true'
    config.x.ccms_soa.aws_gateway_api_key         = ENV['CCMS_SOA_AWS_GATEWAY_API_KEY']
    config.x.ccms_soa.client_username             = ENV['CCMS_SOA_CLIENT_USERNAME']
    config.x.ccms_soa.client_password_type        = ENV['CCMS_SOA_CLIENT_PASSWORD_TYPE']
    config.x.ccms_soa.client_password             = ENV['CCMS_SOA_CLIENT_PASSWORD']
    config.x.ccms_soa.user_role                   = ENV['CCMS_SOA_USER_ROLE']
    config.x.ccms_soa.caseServicesWsdl            = ENV.fetch('CCMS_SOA_CASE_SERVICES_WSDL', 'CaseServicesWsdl.xml')
    config.x.ccms_soa.clientProxyServiceWsdl      = ENV.fetch('CCMS_SOA_CLIENT_PROXY_SERVICE_WSDL', 'ClientProxyServiceWsdl.xml')
    config.x.ccms_soa.documentServicesWsdl        = ENV.fetch('CCMS_SOA_DOCUMENT_SERVICES_WSDL', 'DocumentServicesWsdl.xml')
    config.x.ccms_soa.getReferenceDataWsdl        = ENV.fetch('CCMS_SOA_GET_REFERENCE_DATA_WSDL', 'GetReferenceDataWsdl.xml')

    config.x.google_tag_manager_tracking_id = ENV['GOOGLE_TAG_MANAGER_TRACKING_ID']

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
    config.x.govuk_notify_api_key = ENV['GOVUK_NOTIFY_API_KEY']

    config.x.admin_portal.allow_reset = ENV['ADMIN_ALLOW_RESET'] == 'true'
    config.x.admin_portal.allow_create_test_applications = ENV['ADMIN_ALLOW_CREATE_TEST_APPLICATIONS'] == 'true'
    config.x.admin_portal.show_form = ENV['ADMIN_SHOW_FORM'] == 'true'
    config.x.admin_portal.password = ENV['ADMIN_PASSWORD']

    config.x.email_domain.suffix = ENV['APPLY_EMAIL']

    config.x.provider_details.url = ENV['PROVIDER_DETAILS_URL']

    config.x.metrics_service_host = ENV.fetch('METRICS_SERVICE_HOST', 'localhost')

    config.x.allow_non_passported_route = ENV['ALLOW_NON_PASSPORTED_ROUTE'] != 'false' # true by default

    config.x.check_financial_eligibility_host = ENV['CHECK_FINANCIAL_ELIGIBILITY_HOST']

    config.x.true_layer.client_id = ENV['TRUE_LAYER_CLIENT_ID']
    config.x.true_layer.client_secret = ENV['TRUE_LAYER_CLIENT_SECRET']
    config.x.true_layer.enable_mock = ENV['TRUE_LAYER_ENABLE_MOCK'] == 'true'
    config.x.true_layer.banks = YAML.load_file(Rails.root.join('config/banks.yml'))['banks']

    config.x.geckoboard.api_key = ENV['GECKOBOARD_API_KEY']

    require Rails.root.join 'app/lib/govuk_elements_form_builder/form_builder'
    ActionView::Base.default_form_builder = GovukElementsFormBuilder::FormBuilder

    config.x.google_oauth2.client_id      = ENV['GOOGLE_CLIENT_ID']
    config.x.google_oauth2.client_secret = ENV['GOOGLE_CLIENT_SECRET']

    config.x.db_url = Rails.env.production? ? "postgres://#{ENV['POSTGRES_USER']}:#{ENV['POSTGRES_PASSWORD']}@#{ENV['POSTGRES_HOST']}:5432/#{ENV['POSTGRES_DATABASE']}" : 'postgres://localhost:5432/apply_for_legal_aid_dev' # rubocop:disable Layout/LineLength

    config.active_job.queue_adapter = :sidekiq

    # list geckoboard updater jobs which are suspended by host environment
    config.x.suspended_geckoboard_updater_jobs = {
      development: %w[
        Dashboard::FeedbackItemJob
        Dashboard::ApplicantEmailJob
        Dashboard::ProviderDataJob
        Dashboard::UpdaterJob
      ],
      test: %w[
        Dashboard::FeedbackItemJob
        Dashboard::ApplicantEmailJob
        Dashboard::ProviderDataJob
        Dashboard::UpdaterJob
      ],
      uat: %w[
        Dashboard::FeedbackItemJob
        Dashboard::ApplicantEmailJob
        Dashboard::ProviderDataJob
        Dashboard::UpdaterJob
      ],
      staging: [],
      production: []
    }

    config.x.redis.base_url = ENV['REDIS_HOST'].present? && ENV['REDIS_PASSWORD'].present? ? "rediss://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:6379" : 'redis://localhost:6379' # rubocop:disable Layout/LineLength, Lint/RequireParentheses
    config.x.redis.page_history_url = "#{config.x.redis.base_url}/1"

    # Load array of ip ranges that are allowed to access the Admin pages
    require Rails.root.join('app', 'lib', 'authenticated_ip_ranges')
    config.x.authenticated_ipranges = AuthenticatedIpRanges.ranges
  end
end
