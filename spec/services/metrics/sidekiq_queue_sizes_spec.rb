require "rails_helper"

RSpec.describe Metrics::SidekiqQueueSizes do
  describe "#call" do
    subject(:call_queue_sizes) { described_class.call(prometheus_client) }

    let(:queues) { %w[reports_creator default mailers active_storage_analysis active_storage_purge] }
    let(:prometheus_client) { instance_spy(PrometheusExporter::Client) }
    let(:collector_type) { PrometheusCollectors::SidekiqQueueCollector::COLLECTOR_TYPE }

    it "sends to prometheus the size of each queue" do
      queues.each do |queue|
        expect(prometheus_client).to receive(:send_json).with(
          type: collector_type, queue:, size: Sidekiq::Queue.new(queue).size,
        )
      end
      call_queue_sizes
    end

    context "with known sizes" do
      let(:expected_sizes) { queues.index_with { |_q| rand(0..100) } }

      before do
        queues.each do |queue|
          allow(Sidekiq::Queue)
            .to receive(:new)
            .with(queue)
            .and_return(instance_double(Sidekiq::Queue, size: expected_sizes[queue]))
        end
      end

      it "sends to prometheus the size of each queue" do
        queues.each do |queue|
          expect(prometheus_client).to receive(:send_json).with(
            type: collector_type, queue:, size: expected_sizes[queue],
          )
        end
        call_queue_sizes
      end
    end
  end
end
