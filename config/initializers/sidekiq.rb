require "sidekiq"
require "sidekiq-status"
require "prometheus_exporter/client"
require "prometheus_exporter/instrumentation"

redis_url = "rediss://:#{ENV.fetch('REDIS_PASSWORD', nil)}@#{ENV.fetch('REDIS_HOST', nil)}:6379" if ENV["REDIS_HOST"].present? && ENV["REDIS_PASSWORD"].present?
namespace = ENV.fetch("HOST", "laa-apply")

module Dashboard; end

Sidekiq.configure_client do |config|
  config.logger = Rails.logger
  config.logger.level = Logger::WARN
  config.redis = { url: redis_url, namespace: } if redis_url

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url, namespace: } if redis_url

  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes.to_i

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i

  if Rails.env.production? && Rails.configuration.x.kubernetes_deployment
    config.server_middleware do |chain|
      chain.add PrometheusExporter::Instrumentation::Sidekiq
    end

    config.death_handlers << lambda { |job, _ex|
      PrometheusExporter::Client.default.send_json(
        type: "sidekiq",
        name: job["class"],
        dead: true,
      )
    }

    config.on :startup do
      PrometheusExporter::Instrumentation::Process.start type: "sidekiq"
    end

    at_exit do
      PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
    end
  end
end
