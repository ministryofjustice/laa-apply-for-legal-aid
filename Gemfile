source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

gem 'aasm', '~> 5.1.1'
gem 'active_model_serializers', '~> 0.10.10'
gem 'after_commit_everywhere', '~> 0.1', '>= 0.1.5'
gem 'discard', '~> 1.2'
gem 'geckoboard-ruby'
gem 'govuk_notify_rails', '~> 2.1.2'
gem 'loofah', '>= 2.2.3'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.0.3'
gem 'regexp-examples'
gem 'sass-rails', '~> 6.0', '>= 6.0.0'
gem 'savon', '~> 2.12.1'
gem 'sentry-raven'
gem 'simple_command', github: 'nebulab/simple_command', branch: 'master'
gem 'tzinfo-data'
gem 'webdack-uuid_migration', '~> 1.3.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Authentication
gem 'devise', '>= 4.7.1' # User authentication
gem 'devise_saml_authenticatable', '>= 1.6.2'
gem 'omniauth', '>= 1.9.1'
gem 'omniauth-google-oauth2', '>= 0.8.0'
gem 'omniauth-oauth2', '>= 1.6.0' # Provide Oauth2 strategy framework
gem 'omniauth-rails_csrf_protection', '~> 0.1', '>= 0.1.2'

# Improve backtrace in nested error recues
gem 'nesty'

# Authorization
gem 'pundit'

# Pagination
gem 'pagy'

# Seeding tools
gem 'dibber'
# Gathers data from user browser - OS and Browser name
gem 'browser'

# Used to mock saml request in UAT
gem 'ruby-saml-idp', github: 'dev-develop/ruby-saml-idp', branch: 'master'

# Used to encrypt JSON stored in SecureData
gem 'jwt'

# background processing
gem 'redis-namespace'
gem 'sidekiq', '~> 6.1.2'
gem 'sidekiq_alive', '>= 2.0.1'
gem 'sidekiq-status', '>= 1.1.4'

# Transformer that converts ES6 code into vanilla ES5 using babel via asset pipeline
# Default to 3.7.2 as https://github.com/sass/sassc-rails/issues/122 sassc loading is causing a segmentation error
gem 'sprockets', '~> 3.7.2'
gem 'sprockets-es6', '>= 0.9.2'

# URL and path parsing
gem 'addressable'

# File storage
gem 'aws-sdk-s3'

# convert documnents to PDF
gem 'libreconv'

# Used for working day calculations
gem 'business'

# Monitoring
gem 'prometheus_exporter'

# Generating Fake applications for tests and admin user
gem 'factory_bot_rails', '>= 5.2.0'
gem 'faker', '>=1.9.1'

gem 'webpacker', '~> 5'

gem 'wdm', '>= 0.1.0' if Gem.win_platform?

# generating PDFs
gem 'wicked_pdf'

# interface to manage data
gem 'rails_admin', '~> 2.0', '>= 2.0.2'

# Create reports with SQL queries
gem 'blazer', '>= 2.2.6'

# Manage security headers
gem 'secure_headers'

# Identify file types before uploads
gem 'mimemagic'

group :development, :test do
  gem 'awesome_print', '~> 1.8.0'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails', '>= 2.7.5'
  gem 'erb_lint', require: false
  gem 'htmlentities'
  gem 'i18n-tasks', '>= 0.9.31'
  gem 'json_expressions'
  gem 'nokogiri'
  gem 'pry-byebug'
  gem 'rspec_junit_formatter'
  gem 'rubocop', require: false
  gem 'rubocop-performance'

  # Available in dev env for generators
  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
end

group :development do
  gem 'better_errors', '>= 2.7.1'
  gem 'binding_of_caller'
  gem 'guard-cucumber'
  gem 'guard-livereload'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'listen', '>= 3.0.5', '< 3.4'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'axe-core-cucumber'
  gem 'capybara', '>= 3.32.2', '< 4.0'
  gem 'climate_control' # Allows environment variables to be modified within specs
  gem 'cucumber', require: false
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.4'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'vcr'
  gem 'webdrivers', '~> 4.4'
  gem 'webmock'
end
