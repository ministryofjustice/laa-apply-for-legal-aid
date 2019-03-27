require 'rails_helper'
require 'prometheus_exporter/server'
require "#{Rails.root}/lib/prometheus_collectors/sidekiq_queue_collector"

module PrometheusCollector
  RSpec.describe SidekiqQueueCollector, type: :model do
    let(:collector) { SidekiqQueueCollector.new }

    describe '#type' do
      it 'has a type of sidekiq_queue_sizes' do
        expect(collector.type).to eq 'sidekiq_queue_sizes'
      end
    end

    describe '#metrics' do
      it 'is an array of three gauges' do
        expect(collector.metrics.size).to eq 3
        collector.metrics.each do |metric|
          expect(metric).to be_instance_of(PrometheusExporter::Metric::Gauge)
        end
      end

      it 'has a gauge for each sidekiq queue' do
        expect(collector.metrics.map(&:name)).to eq %w{ sidekiq_queue_default sidekiq_queue_mailers sidekiq_queue_sidekiq_alive }
      end
    end

    describe '#collect' do
      it 'interrogates the size of all three queues' do
        sidekiq_queue = double Sidekiq::Queue
        expect(Sidekiq::Queue).to receive(:new).with('default').and_return(sidekiq_queue)
        expect(Sidekiq::Queue).to receive(:new).with('mailers').and_return(sidekiq_queue)
        expect(Sidekiq::Queue).to receive(:new).with('sidekiq_alive').and_return(sidekiq_queue)
        expect(sidekiq_queue).to receive(:size).and_return(0).exactly(3).times

        SidekiqQueueCollector.new.collect('dummy_object')
      end
    end
  end
end
