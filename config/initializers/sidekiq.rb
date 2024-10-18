require "sidekiq"
require "sidekiq-status"
require "prometheus_exporter/client"
require "prometheus_exporter/instrumentation"

module Dashboard; end

redis_url = Rails.configuration.x.redis.base_url

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
  config.logger.level = Logger::WARN if Rails.env.test?

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes.to_i

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i

  if Rails.env.production? && Rails.configuration.x.kubernetes_deployment
    config.server_middleware do |chain|
      Rails.logger.info "[SidekiqPrometheusExporter] Chaining middleware..."
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end

    config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler

    config.on :startup do
      Rails.logger.info "[SidekiqPrometheusExporter] Startup instrumention details..."

      PrometheusExporter::Instrumentation::Process.start type: "sidekiq"
      PrometheusExporter::Instrumentation::SidekiqProcess.start
      PrometheusExporter::Instrumentation::SidekiqQueue.start(all_queues: true)
      PrometheusExporter::Instrumentation::SidekiqStats.start
    end

    at_exit do
      PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
    end
  end
end
