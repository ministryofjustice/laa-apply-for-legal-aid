require_relative "boot"

require "rails"
require "rails/all"

Bundler.require(*Rails.groups)

module LaaApplyForLegalAid
  class Application < Rails::Application
    config.middleware.use Rack::Attack
    config.load_defaults 7.1
    # If you're upgrading and haven't set `cookies_serializer` previously, your cookie serializer
    # was `:marshal`. Convert all cookies to JSON, using the `:hybrid` formatter.
    #
    # If you're confident all your cookies are JSON formatted, you can switch to the `:json` formatter.
    # Continue to use `:marshal` for backward-compatibility with old cookies.
    #
    # See https://guides.rubyonrails.org/action_controller_overview.html#cookies for more information.
    config.action_dispatch.cookies_serializer = :hybrid
    config.action_mailer.delivery_job = "ActionMailer::MailDeliveryJob"

    # Changes in rails 7.0.3.1 prevented Synbols being used in serialised fields
    # this overrides the setting and allows the code(and tests) to run as normal
    config.active_record.yaml_column_permitted_classes = [Symbol]
    config.time_zone = "London"

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
    end

    # ActiveRecord::Encryption keys generated with `bin/rails db:encryption:init`
    config.active_record.encryption.primary_key = ENV.fetch("ENCRYPTION_PRIMARY_KEY", "fake-primary-key")
    config.active_record.encryption.deterministic_key = ENV.fetch("ENCRYPTION_DETERMINISTIC_KEY", "fake-deterministic-key")
    config.active_record.encryption.key_derivation_salt = ENV.fetch("ENCRYPTION_KEY_DERIVATION_SALT", "fake-key-derivation-salt")

    config.x.application.host             = ENV.fetch("HOST", nil)
    config.x.benefit_check.service_name   = ENV.fetch("BC_LSC_SERVICE_NAME", nil)
    config.x.benefit_check.client_org_id  = ENV.fetch("BC_CLIENT_ORG_ID", nil)
    config.x.benefit_check.client_user_id = ENV.fetch("BC_CLIENT_USER_ID", nil)
    config.x.benefit_check.wsdl_url       = ENV.fetch("BC_WSDL_URL", nil)

    config.x.capital_result.upper_limit = 8000.00
    config.x.capital_result.lower_limit = 3000.00

    config.x.ccms_soa.submit_applications_to_ccms = ENV["CCMS_SOA_SUBMIT_APPLICATIONS"] == "true"
    config.x.ccms_soa.aws_gateway_api_key         = ENV.fetch("CCMS_SOA_AWS_GATEWAY_API_KEY", nil)
    config.x.ccms_soa.client_username             = ENV.fetch("CCMS_SOA_CLIENT_USERNAME", nil)
    config.x.ccms_soa.client_password_type        = ENV.fetch("CCMS_SOA_CLIENT_PASSWORD_TYPE", nil)
    config.x.ccms_soa.client_password             = ENV.fetch("CCMS_SOA_CLIENT_PASSWORD", nil)
    config.x.ccms_soa.user_role                   = ENV.fetch("CCMS_SOA_USER_ROLE", nil)
    config.x.ccms_soa.caseServicesWsdl            = ENV.fetch("CCMS_SOA_CASE_SERVICES_WSDL", "CaseServicesWsdl.xml")
    config.x.ccms_soa.clientProxyServiceWsdl      = ENV.fetch("CCMS_SOA_CLIENT_PROXY_SERVICE_WSDL", "ClientProxyServiceWsdl.xml")
    config.x.ccms_soa.documentServicesWsdl        = ENV.fetch("CCMS_SOA_DOCUMENT_SERVICES_WSDL", "DocumentServicesWsdl.xml")
    config.x.ccms_soa.getReferenceDataWsdl        = ENV.fetch("CCMS_SOA_GET_REFERENCE_DATA_WSDL", "GetReferenceDataWsdl.xml")

    config.x.google_tag_manager_tracking_id = ENV.fetch("GOOGLE_TAG_MANAGER_TRACKING_ID", nil)

    config.x.laa_portal.idp_slo_target_url             = ENV.fetch("LAA_PORTAL_IDP_SLO_TARGET_URL", nil)
    config.x.laa_portal.idp_sso_target_url             = ENV.fetch("LAA_PORTAL_IDP_SSO_TARGET_URL", nil)
    config.x.laa_portal.idp_cert                       = ENV.fetch("LAA_PORTAL_IDP_CERT", nil)
    config.x.laa_portal.idp_cert_fingerprint_algorithm = ENV.fetch("LAA_PORTAL_IDP_CERT_FINGERPRINT_ALGORITHM", nil)
    config.x.laa_portal.mock_saml = ENV.fetch("LAA_PORTAL_MOCK_SAML", nil)

    config.x.laa_portal.certificate = ENV.fetch("LAA_PORTAL_CERTIFICATE", nil)
    config.x.laa_portal.secret_key = ENV.fetch("LAA_PORTAL_SECRET_KEY", nil)

    config.x.kubernetes_deployment = ENV["KUBERNETES_DEPLOYMENT"] == "true"

    config.govuk_notify_templates = YAML.load_file(Rails.root.join("config/govuk_notify_templates.yml")).symbolize_keys

    config.x.support_email_address = "apply-for-civil-legal-aid@digital.justice.gov.uk".freeze
    config.x.govuk_notify_api_key = ENV.fetch("GOVUK_NOTIFY_API_KEY", nil)

    config.x.admin_portal.allow_reset = ENV["ADMIN_ALLOW_RESET"] == "true"
    config.x.admin_portal.allow_create_test_applications = ENV["ADMIN_ALLOW_CREATE_TEST_APPLICATIONS"] == "true"
    config.x.admin_portal.show_form = ENV["ADMIN_SHOW_FORM"] == "true"
    config.x.admin_portal.password = ENV.fetch("ADMIN_PASSWORD", nil)

    config.x.email_domain.suffix = ENV.fetch("APPLY_EMAIL", nil)

    config.x.provider_details.url = ENV.fetch("PROVIDER_DETAILS_URL", nil)

    config.x.legal_framework_api_host = ENV.fetch("LEGAL_FRAMEWORK_API_HOST", nil)
    config.x.legal_framework_api_host_for_js = ENV.fetch("LEGAL_FRAMEWORK_API_HOST_JS", config.x.legal_framework_api_host)

    config.x.metrics_service_host = ENV.fetch("METRICS_SERVICE_HOST", "localhost")

    config.x.cfe_civil_host = ENV.fetch("CFE_CIVIL_HOST", nil)

    config.x.true_layer.client_id = ENV.fetch("TRUE_LAYER_CLIENT_ID", nil)
    config.x.true_layer.client_secret = ENV.fetch("TRUE_LAYER_CLIENT_SECRET", nil)
    config.x.true_layer.enable_mock = ENV["TRUE_LAYER_ENABLE_MOCK"] == "true"
    config.x.true_layer.banks = YAML.load_file(Rails.root.join("config/banks.yml"))["banks"]

    config.x.geckoboard.api_key = ENV.fetch("GECKOBOARD_API_KEY", nil)

    config.x.bc_use_dev_mock = ENV.fetch("BC_USE_DEV_MOCK", nil)
    config.x.ordnance_survey_api_key = ENV.fetch("ORDNANCE_SURVEY_API_KEY", nil)

    config.x.status.build_date = ENV.fetch("BUILD_DATE", "Not Available")
    config.x.status.build_tag = ENV.fetch("BUILD_TAG", "Not Available")
    config.x.status.app_branch = ENV.fetch("APP_BRANCH", "Not Available")

    ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    config.x.google_oauth2.client_id      = ENV.fetch("GOOGLE_CLIENT_ID", nil)
    config.x.google_oauth2.client_secret = ENV.fetch("GOOGLE_CLIENT_SECRET", nil)

    config.x.hmrc_use_dev_mock = ENV["HMRC_USE_DEV_MOCK"] == "true"
    config.x.hmrc_interface.host = ENV.fetch("HMRC_API_HOST", nil)
    config.x.hmrc_interface.client_id = ENV.fetch("HMRC_API_UID", nil)
    config.x.hmrc_interface.client_secret = ENV.fetch("HMRC_API_SECRET", nil)
    config.x.hmrc_interface.duration_check = ENV.fetch("HMRC_DURATION_CHECK", 3)

    config.active_job.queue_adapter = :sidekiq

    config.x.slack_alert_email = ENV.fetch("SLACK_ALERT_EMAIL", nil)

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
      production: [],
    }

    redis_protocol = ENV.fetch("REDIS_PROTOCOL", "rediss")
    redis_password = ENV.fetch("REDIS_PASSWORD", nil)
    redis_host = ENV.fetch("REDIS_HOST", nil)

    redis_url = if redis_host.present? && redis_password.present?
                  "#{redis_protocol}://:#{redis_password}@#{redis_host}:6379"
                else
                  "redis://localhost:6379"
                end
    config.x.redis.base_url = redis_url
    config.x.redis.page_history_url = "#{config.x.redis.base_url}/1"
    config.x.redis.oauth_session_url = "#{config.x.redis.base_url}/2"
    config.x.redis.rack_attack_url = "#{config.x.redis.base_url}/3"

    config.x.maintenance_mode = ENV.fetch("MAINTENANCE_MODE", nil)&.downcase&.eql?("true")

    # automatically include locale in the query string when generating urls with url_helpers
    Rails.application.routes.default_url_options[:locale] = I18n.locale
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en cy] # overriden in test to allow en-GB for Faker

    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/govuk/assets")
    config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")
  end
end
