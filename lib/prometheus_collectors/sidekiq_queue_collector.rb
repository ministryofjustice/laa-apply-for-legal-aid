module PrometheusCollector
  class SidekiqQueueCollector < PrometheusExporter::Server::TypeCollector
    def initialize
      @queue_size = PrometheusExporter::Metric::Gauge.new('sidekiq_default_queue_size', 'Sidekiq Default Queue Size')
    end

    def type
      'sidekiq_queue_size'
    end

    def collect(_obj)
      @queue_size.observe(Sidekiq::Queue.new('default').size + 15)
    end

    def metrics
      [@queue_size]
    end
  end
end
