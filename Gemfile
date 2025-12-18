source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "aasm", "~> 5.5.2"
gem "active_model_serializers", "~> 0.10.16"
gem "csv"
gem "discard", "~> 1.4"
gem "faraday"
gem "govuk_notify_rails", "~> 3.0.0"
gem "net-imap"
gem "net-pop"
gem "net-smtp"
gem "oauth"
gem "ostruct"
gem "pg"
gem "pg_dump_anonymize"
gem "puma"
gem "rack-attack"
gem "rails"
gem "rexml"
gem "sentry-rails", ">= 4.8.0"
gem "sentry-ruby"
gem "sentry-sidekiq"
gem "simple_command"
gem "tzinfo-data"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

# Authentication
gem "devise" # User authentication
gem "omniauth", ">= 2.0.0"
gem "omniauth-oauth2", ">= 1.7.1" # Provide Oauth2 strategy framework
gem "omniauth_openid_connect"
gem "omniauth-rails_csrf_protection", "~> 2.0"

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

# Used to encode sample (mock) TrueLayer transaction IDs as JSON
gem "jwt"

# background processing
gem "redis"
gem "sidekiq", "~> 8.1.0"
gem "sidekiq-status", "~> 4.0.0"

# URL and path parsing
gem "addressable"

# File storage
gem "aws-sdk-s3"

# convert documents to PDF
gem "libreconv"

# Used for working day calculations
gem "business"

# Monitoring
gem "prometheus_exporter"
gem "webrick"

# Generating Fake applications for tests and admin user
gem "factory_bot_rails", ">= 6.2.0"
gem "faker", ">=1.9.1"

# Rails 7 asset management
gem "cssbundling-rails"
gem "jsbundling-rails"
gem "propshaft"

# generating PDFs
gem "grover"

# DFE formbuilder
gem "govuk_design_system_formbuilder"

# ViewComponent
gem "govuk-components"
gem "view_component"

# Catching unsafe migrations in development
gem "strong_migrations"

# Only used for test suite and for mocking certain Provider Data API calls when mock_auth_enabled
gem "webmock"

group :development, :test do
  gem "awesome_print", "~> 1.9.2"
  gem "byebug"
  gem "dotenv"
  gem "erb_lint", "0.9.0", require: false
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
  gem "rspec-rails", "~> 8.0"
end

group :development do
  gem "guard-cucumber"
  gem "guard-livereload"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "listen", ">= 3.0.5", "< 3.10"
  gem "pry-rescue"
  gem "pry-stack_explorer"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

group :test do
  gem "action_dispatch-testing-integration-capybara",
      github: "thoughtbot/action_dispatch-testing-integration-capybara", tag: "v0.2.0",
      require: "action_dispatch/testing/integration/capybara/rspec"
  gem "axe-core-cucumber"
  gem "capybara", ">= 3.36.0", "< 4.0"
  gem "capybara-lockstep"
  gem "cucumber", ">= 9.2.1", require: false
  gem "cucumber-rails", ">= 2.4.0", require: false
  gem "database_cleaner"
  gem "launchy"
  gem "puffing-billy", ">= 4.0.0", require: false
  gem "rack-pjax"
  gem "rails-controller-testing"
  gem "rspec-sidekiq"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 7.0"
  gem "simplecov", require: false
  gem "simplecov-rcov"
  gem "super_diff"
  gem "table_print", require: false
  gem "vcr"
end
