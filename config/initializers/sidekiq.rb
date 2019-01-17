require 'sidekiq'
require 'sidekiq-status'

redis_url = "rediss://:#{ENV['REDIS_PASSWORD']}@#{ENV['REDIS_HOST']}:6379" if ENV['REDIS_HOST'].present? && ENV['REDIS_PASSWORD'].present?

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url } if redis_url

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url } if redis_url

  # accepts :expiration (optional)
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes

  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end
