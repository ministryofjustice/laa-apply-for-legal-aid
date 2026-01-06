require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LaaApplyForLegalAid
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.middleware.use Rack::Attack
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

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

    # we do not use image variants, this prevents a warning
    config.active_storage.variant_processor = :disabled

    config.x.application.host             = ENV.fetch("HOST", nil)
    config.x.benefit_check.service_name   = ENV.fetch("BC_LSC_SERVICE_NAME", nil)
    config.x.benefit_check.client_org_id  = ENV.fetch("BC_CLIENT_ORG_ID", nil)
    config.x.benefit_check.client_user_id = ENV.fetch("BC_CLIENT_USER_ID", nil)
    config.x.benefit_check.wsdl_url       = ENV.fetch("BC_WSDL_URL", nil)

    config.x.capital_result.upper_limit = 8000.00
    config.x.capital_result.lower_limit = 3000.00

    config.x.laa_landing_page_target_url = ENV.fetch("LAA_LANDING_PAGE_TARGET_URL", nil)

    config.x.ccms_soa.submit_applications_to_ccms = ENV["CCMS_SOA_SUBMIT_APPLICATIONS"] == "true"
    config.x.ccms_soa.client_username             = ENV.fetch("CCMS_SOA_CLIENT_USERNAME", nil)
    config.x.ccms_soa.client_password_type        = ENV.fetch("CCMS_SOA_CLIENT_PASSWORD_TYPE", nil)
    config.x.ccms_soa.client_password             = ENV.fetch("CCMS_SOA_CLIENT_PASSWORD", nil)
    config.x.ccms_soa.user_role                   = ENV.fetch("CCMS_SOA_USER_ROLE", nil)
    config.x.ccms_soa.caseServicesWsdl            = ENV.fetch("CCMS_SOA_CASE_SERVICES_WSDL", "CaseServicesUATWsdl.xml")
    config.x.ccms_soa.clientProxyServiceWsdl      = ENV.fetch("CCMS_SOA_CLIENT_PROXY_SERVICE_WSDL", "ClientProxyServiceUATWsdl.xml")
    config.x.ccms_soa.documentServicesWsdl        = ENV.fetch("CCMS_SOA_DOCUMENT_SERVICES_WSDL", "DocumentServicesUATWsdl.xml")
    config.x.ccms_soa.getReferenceDataWsdl        = ENV.fetch("CCMS_SOA_GET_REFERENCE_DATA_WSDL", "GetReferenceDataUATWsdl.xml")

    config.x.google_tag_manager_tracking_id = ENV.fetch("GOOGLE_TAG_MANAGER_TRACKING_ID", nil)

    config.x.kubernetes_deployment = ENV["KUBERNETES_DEPLOYMENT"] == "true"

    config.govuk_notify_templates = YAML.load_file(Rails.root.join("config/govuk_notify_templates.yml")).symbolize_keys

    config.x.support_email_address = "apply-for-civil-legal-aid@justice.gov.uk".freeze
    config.x.online_support = "https://legalaidlearning.justice.gov.uk/online-support-2/".freeze
    config.x.govuk_notify_api_key = ENV.fetch("GOVUK_NOTIFY_API_KEY", nil)

    config.x.admin_portal.allow_reset = ENV["ADMIN_ALLOW_RESET"] == "true"
    config.x.admin_portal.allow_create_test_applications = ENV["ADMIN_ALLOW_CREATE_TEST_APPLICATIONS"] == "true"
    config.x.admin_portal.show_form = ENV["ADMIN_SHOW_FORM"] == "true"

    config.x.email_domain.suffix = ENV.fetch("APPLY_EMAIL", nil)

    config.x.omniauth_entraid.mock_auth_enabled = ENV.fetch("OMNIAUTH_ENTRAID_MOCK_AUTH_ENABLED", "false") == "true"
    config.x.omniauth_entraid.mock_username = ENV.fetch("OMNIAUTH_ENTRAID_MOCK_USERNAME", nil)
    config.x.omniauth_entraid.mock_password = ENV.fetch("OMNIAUTH_ENTRAID_MOCK_PASSWORD", nil)

    config.x.pda.url = ENV.fetch("PDA_URL", nil)
    config.x.pda.auth_key = ENV.fetch("PDA_AUTH_KEY", nil)

    config.x.ccms_user_api.url = ENV.fetch("CCMS_USER_API_URL", nil)
    config.x.ccms_user_api.auth_key = ENV.fetch("CCMS_USER_API_AUTH_KEY", nil)

    config.x.legal_framework_api_host = ENV.fetch("LEGAL_FRAMEWORK_API_HOST", nil)
    config.x.legal_framework_api_host_for_js = ENV.fetch("LEGAL_FRAMEWORK_API_HOST_JS", config.x.legal_framework_api_host)

    # datastore API
    config.x.data_access_api.url = ENV.fetch("DATA_ACCESS_API_URL", nil)

    config.x.metrics_service_host = ENV.fetch("METRICS_SERVICE_HOST", "localhost")

    config.x.cfe_civil_host = ENV.fetch("CFE_CIVIL_HOST", nil)

    config.x.true_layer.client_id = ENV.fetch("TRUE_LAYER_CLIENT_ID", nil)
    config.x.true_layer.client_secret = ENV.fetch("TRUE_LAYER_CLIENT_SECRET", nil)
    config.x.true_layer.enable_mock = ENV["TRUE_LAYER_ENABLE_MOCK"] == "true"
    config.x.true_layer.banks = YAML.load_file(Rails.root.join("config/banks.yml"))["banks"]

    config.x.bc_use_dev_mock = ENV.fetch("BC_USE_DEV_MOCK", nil)
    config.x.ordnance_survey_api_key = ENV.fetch("ORDNANCE_SURVEY_API_KEY", nil)

    config.x.status.build_date = ENV.fetch("BUILD_DATE", "Not Available")
    config.x.status.build_tag = ENV.fetch("BUILD_TAG", "Not Available")
    config.x.status.app_branch = ENV.fetch("APP_BRANCH", "Not Available")

    ActionView::Base.default_form_builder = GOVUKDesignSystemFormBuilder::FormBuilder

    config.x.admin_omniauth.mock_auth_enabled = ENV.fetch("ADMIN_OMNIAUTH_ENTRAID_MOCK_AUTH_ENABLED", nil) == "true"
    config.x.admin_omniauth.mock_username = ENV.fetch("ADMIN_OMNIAUTH_ENTRAID_MOCK_USERNAME", nil)
    config.x.admin_omniauth.mock_password = ENV.fetch("ADMIN_OMNIAUTH_ENTRAID_MOCK_PASSWORD", nil)

    config.x.hmrc_use_dev_mock = ENV["HMRC_USE_DEV_MOCK"] == "true"
    config.x.hmrc_interface.host = ENV.fetch("HMRC_API_HOST", nil)
    config.x.hmrc_interface.client_id = ENV.fetch("HMRC_API_UID", nil)
    config.x.hmrc_interface.client_secret = ENV.fetch("HMRC_API_SECRET", nil)
    config.x.hmrc_interface.duration_check = ENV.fetch("HMRC_DURATION_CHECK", 93)

    config.active_job.queue_adapter = :sidekiq

    config.x.slack_alert_email = ENV.fetch("SLACK_ALERT_EMAIL", nil)

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

    # Configures use of clamav service on hosted/production envs, otherwise use local clamav
    config.x.clamd_conf_filename = ENV.fetch("CLAMD_CONF_FILENAME", "config/clamd.local.conf")

    # Time after which a user will be required to sign in again, regardless of their activity (session lifespan).
    config.x.session.reauthenticate_in = ENV.fetch("REAUTHENTICATE_AFTER_MINUTES", 720).to_i.minutes

    config.x.session.timeout_in = ENV.fetch("IDLE_TIMEOUT_AFTER_MINUTES", 60).to_i.minutes

    # business hours
    config.x.business_hours.start = ENV.fetch("BUSINESS_HOURS_START", "7:00")
    config.x.business_hours.end = ENV.fetch("BUSINESS_HOURS_END", "21:30")

    # TODO: The bank_holidays array needs handling and is only added here as a temporary fix for
    # out of hours implementation over the Christmas holidays of 2025 - by Easter 2026 we should
    # be able to handle this better using the BankHoliday model
    config.x.bank_holidays = %w[2025-12-25 2025-12-26 2026-01-01]
    config.x.bank_holidays_url = "https://www.gov.uk/bank-holidays.json"

    # automatically include locale in the query string when generating urls with url_helpers
    Rails.application.routes.default_url_options[:locale] = I18n.locale
    config.i18n.default_locale = :en
    config.i18n.available_locales = %i[en cy] # overriden in test to allow en-GB for Faker

    config.assets.paths << Rails.root.join("node_modules/govuk-frontend/dist/govuk/assets")
    config.assets.excluded_paths << Rails.root.join("app/assets/stylesheets")

    config.exceptions_app = lambda { |env|
      ErrorsController.action(:show).call(env)
    }
  end
end
