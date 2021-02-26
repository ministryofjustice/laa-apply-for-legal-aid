# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'json_expressions/rspec'
require 'awesome_print'
require 'pry-rescue/rspec' if Rails.env.development?

# Add additional requires below this line. Rails is not loaded until this point!
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  include MoneyHelper
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include FactoryBot::Syntax::Methods
  config.include RequestHelpers, type: :request
  config.include TrueLayerHelpers
  config.include OmniauthPathHelper
  config.include FlowHelpers, type: :request
  config.include ActiveSupport::Testing::TimeHelpers
  config.include CCMS
  config.include XMLBlockMatchers
  config.before(:suite) do
    Faker::Config.locale = 'en-GB'
    DatabaseCleaner.clean_with :truncation
  end

  # Add support for Devise authentication helpers
  # https://github.com/plataformatec/devise#controller-tests
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose one or more libraries:
    with.library :rails
  end
end

# Modify ENV variables within a spec. See:
#   https://github.com/thoughtbot/climate_control
def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end

def uploaded_file(path, content_type = nil, binary: false)
  Rack::Test::UploadedFile.new(Rails.root.join(path), content_type, binary)
end

# method to enable session vars to be set in request spec.
# uses the test_session_path route which is only available in test env.
def set_session(vars = {}) # rubocop:disable Naming/AccessorMethodName
  return if vars.empty?

  my_params = { session_vars: vars.to_json }

  post test_session_path, params: my_params
  expect(response).to have_http_status(:created)

  vars.each_key do |var|
    expect(session[var]).to be_present
  end
end

# encodes strings to HTML so that comparisons like "O'Keefe & Sons" don't fail
# for some reason, most entities are translated to their named equivalent, e.g. &amp;
# but apostrophes are translated to decimal equivalent, '&#39;'
#
def html_compare(string)
  HTMLEntities.new.encode(string).gsub('&apos;', '&#39;')
end

def populate_legal_framework
  ServiceLevel.populate
  ProceedingType.populate
  ScopeLimitation.populate
  ProceedingTypeScopeLimitation.populate
end
