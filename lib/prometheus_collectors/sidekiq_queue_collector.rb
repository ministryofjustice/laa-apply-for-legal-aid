module PrometheusCollector
  class SidekiqQueueCollector < PrometheusExporter::Server::TypeCollector
    QUEUE_NAMES = {
      default: 'Default Sidekiq queue size',
      mailers: 'Mailers Sidekiq queue size',
      sidekiq_alive: 'Sidekiq-Alive Sidekiq queue size'
    }

    def initialize
      @collectors = []
      QUEUE_NAMES.each do |queue_name, description|
        @collectors << PrometheusExporter::Metric::Gauge.new(queue_name.to_s, description)
      end
    end

    def type
      'sidekiq_queue_sizes'
    end

    def collect(_obj)
      @collectors.each do |collector|
        size = Sidekiq::Queue.new(collector.name.to_s).size
        collector.observe(size)
      end
    end

    def metrics
      @collectors
    end
  end
end
