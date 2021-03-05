require 'sentry-ruby'
require 'sentry-rails'
require 'sentry-sidekiq'

if %w[production].include?(Rails.env) && ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']

    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters.map(&:to_s))

    config.before_send = ->(event, _hint) {
      event.extra[:sidekiq][:job]['args'].first['arguments'] = [] if event.extra.dig(:sidekiq, :job, 'args')

      event.extra[:sidekiq][:jobstr] = {} if event.extra.dig(:sidekiq, :jobstr)

      event.request.data = filter.filter(event.request&.data || []) if event.request&.data

      event
    }
  end
end
