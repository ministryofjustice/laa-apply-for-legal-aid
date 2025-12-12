class PdfConverterWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  class SentryIgnoreThisSidekiqFailError < StandardError; end

  attr_accessor :retry_count

  ALERT_ON_RETRY_COUNT = 3
  sidekiq_options retry: ALERT_ON_RETRY_COUNT
  sidekiq_retries_exhausted do |msg, _ex|
    Sentry.capture_message Sidekiq::ExhaustedFailureMessage.call(msg)
  end

  def perform(attachment_id)
    PdfConverter.call(attachment_id)
  rescue StandardError => e
    raise if retry_count.eql? ALERT_ON_RETRY_COUNT

    raise SentryIgnoreThisSidekiqFailError, "Attempt to convert file to PDF failed on retry #{retry_count.to_i} with error #{e.message}"
  end
end
