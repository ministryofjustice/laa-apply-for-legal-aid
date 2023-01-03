source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

gem "aasm", "~> 5.4.0"
gem "active_model_serializers", "~> 0.10.13"
gem "data_migrate"
gem "discard", "~> 1.2"
gem "geckoboard-ruby"
gem "google_drive", ">= 3.0.7"
gem "govuk_notify_rails", "~> 2.2.0"
gem "net-imap"
gem "net-pop"
gem "net-smtp"
gem "oauth"
gem "pg"
gem "pg_dump_anonymize"
gem "puma"
gem "rack-attack"
gem "rails"
gem "rexml"
gem "savon", "~> 2.13.1"
gem "sentry-rails", ">= 4.8.0"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "simple_command"
gem "tzinfo-data"
gem "webdack-uuid_migration", "~> 1.4.0"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Authentication
gem "devise", ">= 4.8.0" # User authentication
gem "devise_saml_authenticatable", ">= 1.7.0"
gem "omniauth", ">= 2.0.0"
gem "omniauth-google-oauth2", ">= 0.8.1"
gem "omniauth-oauth2", ">= 1.7.1" # Provide Oauth2 strategy framework
gem "omniauth-rails_csrf_protection", "~> 1.0"

# Improve backtrace in nested error recues
gem "nesty"

# Authorization
gem "pundit"

# Pagination
gem "pagy"

# Seeding tools
gem "dibber"
# Gathers data from user browser - OS and Browser name
gem "browser"

# Used to mock saml request in UAT
gem "ruby-saml-idp", github: "dev-develop/ruby-saml-idp", branch: "master"

# Used to encrypt JSON stored in SecureData
gem "jwt"

# background processing
gem "redis-namespace"
gem "sidekiq", "~> 6.5.7"
gem "sidekiq-status", "~> 2.1.3"

# URL and path parsing
gem "addressable"

# File storage
gem "aws-sdk-s3"

# convert documents to PDF
gem "libreconv"

# Used for working day calculations
gem "business"

# Monitoring
gem "prometheus_exporter", "=0.4.17"
gem "webrick"

# Generating Fake applications for tests and admin user
gem "factory_bot_rails", ">= 6.2.0"
gem "faker", ">=1.9.1"

gem "webpacker", "~> 5", ">= 5.4.3"

gem "wdm", ">= 0.1.0" if Gem.win_platform?

# generating PDFs
gem "grover"

# DFE formbuilder
gem "govuk_design_system_formbuilder"

# DFE ViewComponent library
gem "govuk-components"

# Catching unsafe migrations in development
gem "strong_migrations"

group :development, :test do
  gem "awesome_print", "~> 1.9.2"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails", ">= 2.7.6"
  gem "erb_lint", "0.3.1", require: false
  gem "hirb"
  gem "htmlentities"
  gem "i18n-tasks"
  gem "json_expressions"
  gem "nokogiri", ">= 1.12.5"
  gem "overcommit"
  gem "pry-byebug"
  gem "rspec_junit_formatter"
  gem "rubocop-govuk", require: false
  gem "rubocop-performance"

  # Available in dev env for generators
  gem "rspec-rails", "~> 6.0"
end

group :development do
  gem "guard-cucumber"
  gem "guard-livereload"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "listen", ">= 3.0.5", "< 3.8"
  gem "pry-rescue"
  gem "pry-stack_explorer"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

group :test do
  gem "action_dispatch-testing-integration-capybara",
      github: "thoughtbot/action_dispatch-testing-integration-capybara", tag: "v0.1.0",
      require: "action_dispatch/testing/integration/capybara/rspec"
  gem "axe-core-cucumber"
  gem "capybara", ">= 3.36.0", "< 4.0"
  gem "cucumber", require: false
  gem "cucumber-rails", ">= 2.4.0", require: false
  gem "database_cleaner"
  gem "launchy"
  gem "rack-pjax"
  gem "rails-controller-testing"
  gem "rspec-sidekiq"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 5.3"
  gem "simplecov", require: false
  gem "simplecov-rcov"
  gem "super_diff"
  gem "vcr"
  gem "webdrivers", "~> 5.2"
  gem "webmock"
end
