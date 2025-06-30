require "rspec-sidekiq"
require "sidekiq/testing"

RSpec::Sidekiq.configure do |config|
  config.clear_all_enqueued_jobs = true # default => true
  config.enable_terminal_colours = true # default => true
  config.warn_when_jobs_not_processed_by_sidekiq = false # default => true
end
