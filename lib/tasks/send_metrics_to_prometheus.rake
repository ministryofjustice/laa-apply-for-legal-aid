desc 'Send metrics to prometheus'
task send_metrics_to_prometheus: :environment do
  Metrics::SendMetrics.call
end
