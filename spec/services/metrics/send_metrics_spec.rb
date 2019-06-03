require 'rails_helper'

RSpec.describe Metrics::SendMetrics do
  describe '#call' do
    let(:metrics_service_host) { Faker::Internet.domain_word }
    let(:prometheus_client) { spy(PrometheusExporter::Client) }
    let(:prometheus_thread_sleep) { rand(1..10).to_f / 1000 }
    subject { described_class.call }

    before do
      stub_const('Metrics::SendMetrics::PROMETHEUS_THREAD_SLEEP', prometheus_thread_sleep)
      allow(PrometheusExporter::Client).to receive(:new).and_return(prometheus_client)
      allow(Rails.configuration.x).to receive(:metrics_service_host).and_return(metrics_service_host)
    end

    it 'creates a prometheus client with the right settings' do
      expect(PrometheusExporter::Client)
        .to receive(:new)
        .with(host: metrics_service_host, thread_sleep: prometheus_thread_sleep)
        .and_return(prometheus_client)
      subject
    end

    it 'sleeps during twice the time of a prometheus loop' do
      allow_any_instance_of(Object).to receive(:sleep).with(prometheus_thread_sleep * 2)
      subject
    end

    it 'sends to prometheus the size of sidekiq queues' do
      expect(Metrics::SidekiqQueueSizes).to receive(:call).with(prometheus_client).and_call_original
      expect(prometheus_client).to receive(:send_json).with(
        hash_including(
          type: PrometheusCollectors::SidekiqQueueCollector::COLLECTOR_TYPE,
          queue: 'mailers'
        )
      )
      subject
    end
  end
end
