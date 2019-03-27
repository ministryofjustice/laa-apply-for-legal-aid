namespace :prometheus do
  desc 'Measure sidekiq queue sizes and send to prometheus'
  task sidekiq_queues: :environment do
    PrometheusExporter::Client.default.send_json(type: 'sidekiq_queue_sizes')
  end
end
