module Metrics
  class SendMetrics
    PROMETHEUS_THREAD_SLEEP = 0.1 # seconds

    def self.call
      new.call
    end

    def call
      Metrics::SidekiqQueueSizes.call(prometheus_client)

      # prometheus_exporter runs in a loop and we need to give it some time to send the metrics
      # https://github.com/discourse/prometheus_exporter/blob/master/lib/prometheus_exporter/client.rb#L54
      sleep PROMETHEUS_THREAD_SLEEP * 2
    end

    private

    def prometheus_client
      @prometheus_client ||= PrometheusExporter::Client.new(
        host: Rails.configuration.x.metrics_service_host,
        thread_sleep: PROMETHEUS_THREAD_SLEEP
      )
    end
  end
end
