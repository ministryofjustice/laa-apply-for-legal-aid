require 'rails_helper'
require 'prometheus_exporter/server'
require "#{Rails.root}/lib/prometheus_collectors/sidekiq_queue_collector"

module PrometheusCollector
  RSpec.describe SidekiqQueueCollector, type: :model do
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
