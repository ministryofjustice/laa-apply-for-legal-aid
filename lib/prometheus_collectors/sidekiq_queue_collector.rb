module PrometheusCollector
  class SidekiqQueueCollector < PrometheusExporter::Server::TypeCollector
    GAUGE_NAMES = {
      sidekiq_queue_default: 'Default Sidekiq queue size',
      sidekiq_queue_mailers: 'Mailers Sidekiq queue size',
      sidekiq_queue_sidekiq_alive: 'Sidekiq-Alive Sidekiq queue size'
    }.freeze

    def initialize
      @gauges = []
      GAUGE_NAMES.each do |gauge_name, description|
        @gauges << PrometheusExporter::Metric::Gauge.new(gauge_name.to_s, description)
      end
    end

    def type
      'sidekiq_queue_sizes'
    end

    def collect(_obj)
      @gauges.each do |gauge|
        size = Sidekiq::Queue.new(queue_name(gauge)).size
        gauge.observe(size)
      end
    end

    def metrics
      @gauges
    end

    private

    def queue_name(gauge)
      gauge.name.sub(/^sidekiq_queue_/, '')
    end
  end
end
