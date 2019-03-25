require 'sidekiq'
require 'sidekiq-status'
require 'prometheus_exporter/client'
require 'prometheus_exporter/instrumentation'
require 'prometheus_exporter/metric'

redis_url = "rediss://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:6379" if ENV['REDIS_HOST'].present? && ENV['REDIS_PASSWORD'].present?
namespace = ENV.fetch('HOST', 'laa-apply')

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

  config.server_middleware do |chain|
    chain.add PrometheusExporter::Instrumentation::Sidekiq
  end

  death_handler = ->(job, _ex) do
    PrometheusExporter::Client.default.send_json(
      type: 'sidekiq',
      name: job['class'],
      dead: true
    )
  end

  config.death_handlers << death_handler

  config.on :startup do
    require 'prometheus_exporter/instrumentation'
    PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
  end

  at_exit do
    PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
  end
end
