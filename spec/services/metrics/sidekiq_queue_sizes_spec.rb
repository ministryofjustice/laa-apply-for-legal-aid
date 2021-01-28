require 'rails_helper'

RSpec.describe Metrics::SidekiqQueueSizes do
  describe '#call' do
    let(:queues) { %w[default mailers sidekiq_alive active_storage_analysis active_storage_purge] }
    let(:prometheus_client) { spy(PrometheusExporter::Client) }
    let(:collector_type) { PrometheusCollectors::SidekiqQueueCollector::COLLECTOR_TYPE }
    subject { described_class.call(prometheus_client) }

    it 'sends to prometheus the size of each queue' do
      queues.each do |queue|
        expect(prometheus_client).to receive(:send_json).with(
          type: collector_type, queue: queue, size: Sidekiq::Queue.new(queue).size
        )
      end
      subject
    end

    context 'with known sizes' do
      let(:expected_sizes) { queues.index_with { |_q| rand(0..100) } }

      before do
        queues.each do |queue|
          allow(Sidekiq::Queue)
            .to receive(:new)
            .with(queue)
            .and_return(double('Queue', size: expected_sizes[queue]))
        end
      end

      it 'sends to prometheus the size of each queue' do
        queues.each do |queue|
          expect(prometheus_client).to receive(:send_json).with(
            type: collector_type, queue: queue, size: expected_sizes[queue]
          )
        end
        subject
      end
    end
  end
end
