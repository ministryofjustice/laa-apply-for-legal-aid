require "rails_helper"
require "prometheus_exporter/server"

RSpec.describe PrometheusCollectors::SidekiqQueueCollector do
  subject(:collector) { described_class.new }

  let(:queue) { "mailers" }
  let(:gauge) { spy(PrometheusExporter::Metric::Gauge) }
  let(:queue_size) { rand(1..100) }

  before do
    allow(PrometheusExporter::Metric::Gauge)
      .to receive(:new)
      .and_return(gauge)
  end

  it "has the right type" do
    expect(collector.type).to eq(PrometheusCollectors::SidekiqQueueCollector::COLLECTOR_TYPE)
  end

  it "has one gauge" do
    expect(collector.metrics.size).to eq(1)
    expect(collector.metrics.first).to be(gauge)
  end

  it "sends the queue size to the prometheus gauge" do
    expect(gauge).to receive(:observe).with(queue_size, queue:)
    collector.collect("queue" => queue, "size" => queue_size)
  end
end
