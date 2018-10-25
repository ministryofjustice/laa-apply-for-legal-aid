require_relative 'boot'

require "rails/all"

Bundler.require(*Rails.groups)

module LaaApplyForLegalaidApi
  class Application < Rails::Application
    config.load_defaults 5.2

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.govuk_notify_templates = config_for(
      :govuk_notify_templates, env: ENV.fetch('GOVUK_NOTIFY_ENV', 'development')
    ).symbolize_keys
  end
end
