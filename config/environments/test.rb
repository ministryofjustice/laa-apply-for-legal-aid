# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  # config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with cache-control for performance.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Show full error reports.
  config.consider_all_requests_local = true
  config.cache_store = :null_store

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.x.benefit_check.wsdl_url = "https://uat.laa-benefit-checker.service.justice.gov.uk/lsx/lsc-services/benefitChecker?wsdl"

  config.x.logs_faraday_response = false

  config.x.laa_landing_page_target_url = "https://example.com/"

  # Policy Disregards feature flag
  config.x.policy_disregards_start_date = Date.parse("2021-1-8")

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions.
  config.action_controller.raise_on_missing_callback_actions = true

  Rails.application.routes.default_url_options[:host] = "www.example.com"

  config.active_storage.service = :test
  config.x.application.host = "test"
  config.x.application.host_url = "http://#{config.x.application.host}"

  config.x.email_domain.suffix = "@test.test"

  unless ENV["RAILS_ENABLE_TEST_LOG"]
    config.logger = ActiveSupport::Logger.new(nil)
    config.log_level = :fatal
  end

  config.x.legal_framework_api_host = ENV.fetch("LEGAL_FRAMEWORK_API_HOST", "https://legal-framework-api-staging.cloud-platform.service.justice.gov.uk")
  config.x.pda.url = ENV.fetch("PDA_URL", "https://laa-provider-details-api-uat.apps.live.cloud-platform.service.justice.gov.uk")
  config.x.ccms_user_api.url = ENV.fetch("CCMS_USER_API_URL", "https://laa-ccms-user-details-api-dev.apps.live.cloud-platform.service.justice.gov.uk/api/v1")
  config.x.data_access_api.url = ENV.fetch("DATA_ACCESS_API_URL", "https://laa-data-access-api-uat.apps.live.cloud-platform.service.justice.gov.uk/api/v0")

  # allow en-GB locale in test environment for Faker
  config.i18n.available_locales = %i[en cy en-GB]

  # This needs adding due to a rails 7.1.1 bug(?!) related to Unsafe threading and AR connection pool issues
  # see https://github.com/rails/rails/issues/46797 for a good description
  config.active_job.queue_adapter = :test

  config.middleware.insert_before 0, Capybara::Lockstep::Middleware

  # set off by default to allow stubbing and mocks to be used for testing on a case by case basis
  config.x.omniauth_entraid.mock_auth_enabled = false
  config.x.omniauth_entraid.mock_username = "test@test.com"
  config.x.omniauth_entraid.mock_password = "not-a-real-password"

  config.x.admin_omniauth.mock_auth_enabled = false
  config.x.admin_omniauth.mock_username = "apply-for-civil-legal-aid@justice.gov.uk"
  config.x.admin_omniauth.mock_password = "not-a-real-password"

  # business hours
  config.x.business_hours.start = ENV.fetch("BUSINESS_HOURS_START", "00:00")
  config.x.business_hours.end = ENV.fetch("BUSINESS_HOURS_END", "23:59")
end
