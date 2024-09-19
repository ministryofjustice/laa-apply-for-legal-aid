Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = false

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}",
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  config.action_mailer.perform_caching = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  config.x.benefit_check.wsdl_url = "https://benefitchecker.stg.legalservices.gov.uk/lsx/lsc-services/benefitChecker?wsdl"

  config.x.logs_faraday_response = false

  config.x.laa_portal.idp_sso_target_url = "https://example.com/sso"
  config.x.laa_portal.idp_cert = "laa-portal.cert"
  config.x.laa_portal.idp_cert_fingerprint_algorithm = "http://www.w3.org/2000/09/xmldsig#sha"

  # Policy Disregards feature flag
  config.x.policy_disregards_start_date = Date.parse("2021-1-8")

  # Raises error for missing translations
  config.i18n.raise_on_missing_translations = true

  Rails.application.routes.default_url_options[:host] = "www.example.com"

  config.active_storage.service = :test
  config.x.application.host = "test"
  config.x.application.host_url = "http://#{config.x.application.host}"

  config.x.email_domain.suffix = "@test.test"

  unless ENV["RAILS_ENABLE_TEST_LOG"]
    config.logger = ActiveSupport::Logger.new(nil)
    config.log_level = :fatal
  end

  # Dummy url for provider details api
  config.x.provider_details.url = "http://dummy-provider-details-api/"

  # Test url for provider details api
  config.x.pda.url = "https://laa-provider-details-api-uat.apps.live.cloud-platform.service.justice.gov.uk"

  # allow en-GB locale in test environment for Faker
  config.i18n.available_locales = %i[en cy en-GB]

  # set the id of the Digest Export spreadsheet to use in this environment
  config.x.digest_export.spreadsheet_id = "1dXnEdiqqP_fOeWzDsbXY83lwwK8pvf8j4jsUqaGnGMs"

  # This needs adding due to a rails 7.1.1 bug(?!) related to Unsafe threading and AR connection pool issues
  # see https://github.com/rails/rails/issues/46797 for a good description
  config.active_job.queue_adapter = :test
end
