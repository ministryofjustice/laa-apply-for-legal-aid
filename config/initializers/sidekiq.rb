require 'sidekiq'
require 'sidekiq-status'
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'

redis_url = "rediss://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:6379" if ENV['REDIS_HOST'].present? && ENV['REDIS_PASSWORD'].present?
namespace = ENV.fetch('HOST', 'laa-apply')

module Dashboard; end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, namespace: namespace } if redis_url

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: namespace } if redis_url

  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes

  if Rails.env.production? && Rails.configuration.x.kubernetes_deployment
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end

    config.death_handlers << ->(job, _ex) do
      PrometheusExporter::Client.default.send_json(
        type: 'sidekiq',
        name: job['class'],
        dead: true
      )
    end

    config.on :startup do
      PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
    end

    at_exit do
      PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
    end
  end
end
