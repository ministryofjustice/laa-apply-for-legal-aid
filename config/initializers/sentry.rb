require "sentry-ruby"
require "sentry-rails"
require "sentry-sidekiq"
require "active_support/parameter_filter"

if %w[production].include?(Rails.env) && ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV.fetch("SENTRY_DSN", nil)

    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters.map(&:to_s))
    config.excluded_exceptions += %w[
      CCMS::SentryIgnoreThisSidekiqFailError
      HMRC::SentryIgnoreThisSidekiqFailError
      PdfConverterWorker::SentryIgnoreThisSidekiqFailError
    ]

    config.before_send = lambda { |event, _hint|
      event.extra[:sidekiq][:job]["args"].first["arguments"] = [] if event.extra.dig(:sidekiq, :job, "args")

      event.extra[:sidekiq][:jobstr] = {} if event.extra.dig(:sidekiq, :jobstr)

      event.request.data = filter.filter(event.request&.data || []) if event.request&.data

      event
    }
  end
end
