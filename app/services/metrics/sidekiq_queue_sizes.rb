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
        queue:,
        size: queue_size(queue),
      )
    end

    def queue_size(queue)
      Sidekiq::Queue.new(queue).size
    end

    def queues
      sidekiq_config = Rails.root.join("config/sidekiq.yml").read
      YAML.safe_load(sidekiq_config, permitted_classes: [Symbol])[:queues]
    end
  end
end
