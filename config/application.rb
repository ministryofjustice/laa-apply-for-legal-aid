require_relative 'boot'

require "rails/all"
require 'sprockets/es6'

Bundler.require(*Rails.groups)

module LaaApplyForLegalAid
  class Application < Rails::Application
    config.load_defaults 5.2

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
      g.test_framework :rspec
    end

    config.x.benefit_check.service_name   = ENV['BC_LSC_SERVICE_NAME']
    config.x.benefit_check.client_org_id  = ENV['BC_CLIENT_ORG_ID']
    config.x.benefit_check.client_user_id = ENV['BC_CLIENT_USER_ID']
    config.x.benefit_check.wsdl_url       = ENV['BC_WSDL_URL']

    config.govuk_notify_templates = config_for(
      :govuk_notify_templates, env: ENV.fetch('GOVUK_NOTIFY_ENV', 'development')
    ).symbolize_keys

    require Rails.root.join 'app/lib/govuk_elements_form_builder/form_builder'
    ActionView::Base.default_form_builder = GovukElementsFormBuilder::FormBuilder
  end
end
