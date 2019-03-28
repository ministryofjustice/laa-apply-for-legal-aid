if Rails.env.production? && Rails.configuration.x.kubernetes_deployment
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/middleware'
  require 'prometheus_exporter/middleware'

  PrometheusExporter::Instrumentation::Process.start(type: 'master')
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end
