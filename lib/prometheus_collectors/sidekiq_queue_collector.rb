module PrometheusCollector
  class SidekiqQueueCollector < PrometheusExporter::Server::TypeCollector
    def initialize
      @queue_size = PrometheusExporter::Metric::Gauge.new('sidekiq_queue_size', 'Sidekiq Queue Size')
    end

    def type
      'sidekiq_queue_size'
    end

    def collect(_obj)
      @queue_size.observe(rand(5))
    end

    def metrics
      [@queue_size]
    end
  end
end
