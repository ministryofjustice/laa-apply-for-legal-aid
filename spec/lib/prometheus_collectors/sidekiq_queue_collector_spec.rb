require 'rails_helper'
require 'prometheus_exporter/server'

RSpec.describe PrometheusCollectors::SidekiqQueueCollector do
  let(:queue) { 'mailers' }
  let(:gauge) { spy(PrometheusExporter::Metric::Gauge) }
  let(:queue_size) { rand(1..100) }
  subject { described_class.new }

  before do
    allow(PrometheusExporter::Metric::Gauge)
      .to receive(:new)
      .and_return(gauge)
  end

  it 'has the right type' do
    expect(subject.type).to eq(PrometheusCollectors::SidekiqQueueCollector::COLLECTOR_TYPE)
  end

  it 'has one gauge' do
    expect(subject.metrics.size).to eq(1)
    expect(subject.metrics.first).to be(gauge)
  end

  it 'sends the queue size to the prometheus gauge' do
    expect(gauge).to receive(:observe).with(queue_size, queue: queue)
    subject.collect('queue' => queue, 'size' => queue_size)
  end
end
