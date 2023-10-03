require "sidekiq"
require "sidekiq-status"
require "prometheus_exporter/client"
require "prometheus_exporter/instrumentation"

redis_url = "rediss://:#{ENV.fetch('REDIS_PASSWORD', nil)}@#{ENV.fetch('REDIS_HOST', nil)}:6379" if ENV["REDIS_HOST"].present? && ENV["REDIS_PASSWORD"].present?
namespace = ENV.fetch("HOST", "laa-apply")

module Dashboard; end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url } if redis_url

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

Sidekiq.configure_server do |config|
  if redis_url
    config.redis = if ENV.fetch("NAMEPSPACED_SIDEKIQ_DRAINER", nil)
                     { url: redis_url, namespace: } # continue to poll for old scheduled jobs and retries
                   else
                     { url: redis_url }
                   end
  end

  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes

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
