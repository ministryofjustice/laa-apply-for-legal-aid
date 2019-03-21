source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.3'

gem 'aasm', '~> 5.0.3'
gem 'active_model_serializers', '~> 0.10.9'
gem 'govuk_notify_rails', '~> 2.1.0'
gem 'jquery-rails', '~> 4.3', '>= 4.3.3'
gem 'loofah', '>= 2.2.3'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'rails', '~> 5.2.3'
gem 'regexp-examples'
gem 'sass-rails', '~> 5.0'
gem 'savon', '~> 2.12.0'
gem 'sentry-raven'
gem 'simple_command', '~> 0.0.9'
gem 'uglifier', '>= 1.3.0'
gem 'webdack-uuid_migration', '~> 1.2.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Authentication
gem 'devise' # User authentication
gem 'devise_saml_authenticatable'
gem 'omniauth'
gem 'omniauth-oauth2' # Provide Oauth2 strategy framework

# Authorization
gem 'pundit'

# Pagination
gem 'pagy'

# Gathers data from user browser - OS and Browser name
gem 'browser'

# Used to mock saml request in UAT
gem 'ruby-saml-idp'

# Used to encrypt JSON stored in SecureData
gem 'jwt'

# background processing
gem 'redis-namespace'
gem 'sidekiq'
gem 'sidekiq-status'
gem 'sidekiq_alive'

# Transformer that converts ES6 code into vanilla ES5 using babel via asset pipeline
gem 'sprockets', '>= 3.0.0'
gem 'sprockets-es6'

# URL and path parsing
gem 'addressable'

# File storage
gem 'aws-sdk-s3'

# convert documnents to PDF
gem 'libreconv'

# Monitoring
gem 'prometheus_exporter'

# Generating Fake applications for tests and admin user
gem 'factory_bot_rails'
gem 'faker', '>=1.9.1'

group :development, :test do
  gem 'awesome_print', '~> 1.8.0'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'erb_lint', require: false
  gem 'i18n-tasks'
  gem 'json_expressions'
  gem 'nokogiri'
  gem 'pry-byebug'
  gem 'rubocop', require: false

  # Available in dev env for generators
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15', '< 4.0'
  gem 'chromedriver-helper'
  gem 'climate_control' # Allows environment variables to be modified within specs
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'launchy'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 4.0'
  gem 'simplecov', require: false
  gem 'simplecov-rcov'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
