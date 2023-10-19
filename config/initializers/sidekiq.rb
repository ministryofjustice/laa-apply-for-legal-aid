require "sidekiq"
require "sidekiq-status"
require "prometheus_exporter/client"
require "prometheus_exporter/instrumentation"

module Dashboard; end

redis_url = Rails.configuration.x.redis.base_url

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

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
