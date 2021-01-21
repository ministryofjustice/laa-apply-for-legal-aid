module Metrics
  class SidekiqQueueSizes
    def self.call(prometheus_client)
      new(prometheus_client).call
    end

    def initialize(prometheus_client)
      @prometheus_client = prometheus_client
    end

    def call
      queues.each { |queue| send_metric(queue) }
    end

    private

    attr_reader :prometheus_client

    def send_metric(queue)
      prometheus_client.send_json(
        type: PrometheusCollectors::SidekiqQueueCollector::COLLECTOR_TYPE,
        queue: queue,
        size: queue_size(queue)
      )
    end

    def queue_size(queue)
      Sidekiq::Queue.new(queue).size
    end

    def queues
      sidekiq_config = File.read(Rails.root.join('config/sidekiq.yml'))
      YAML.safe_load(sidekiq_config, [Symbol])[:queues]
    end
  end
end
