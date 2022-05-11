module DurationLogger
  def log_duration(message, &block)
    started = Time.zone.now
    yield block
    total_duration = ActiveSupport::Duration.build(Time.zone.now - started).inspect
    Rails.logger.info("#{message} took #{total_duration}")
  end
end
