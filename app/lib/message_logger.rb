module MessageLogger
  def log_message(message)
    message = "#{self.class}:: #{message}"
    message = Time.zone.now.strftime("%F %T.%L ") + message if Rails.env.development?
    Rails.logger.info message
  end
end
