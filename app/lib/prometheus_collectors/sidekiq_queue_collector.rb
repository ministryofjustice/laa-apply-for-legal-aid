require 'prometheus_exporter/server'

module PrometheusCollectors
  class SidekiqQueueCollector < PrometheusExporter::Server::TypeCollector
    COLLECTOR_TYPE = 'sidekiq_queue_size'.freeze

    def initialize
      super
      @gauge = PrometheusExporter::Metric::Gauge.new(COLLECTOR_TYPE, 'Sidekiq queue size')
    end

    def type
      COLLECTOR_TYPE
    end

    def collect(obj)
      @gauge.observe(obj['size'], queue: obj['queue'])
    end

    def metrics
      [@gauge]
    end
  end
end
