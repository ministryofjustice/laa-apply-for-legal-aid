class PdfConverterWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  class SentryIgnoreThisSidekiqFailError < StandardError; end

  attr_accessor :retry_count

  MAX_RETRIES = 5
  sidekiq_options retry: MAX_RETRIES
  sidekiq_retries_exhausted do |msg, _ex|
    Sentry.capture_message Sidekiq::ExhaustedFailureMessage.call(msg)
  end

  def perform(attachment_id)
    CreatePdfAttachment.call(attachment_id)
  rescue StandardError => e
    raise if should_warn?

    raise SentryIgnoreThisSidekiqFailError, "Attempt to convert file (attachment_id: #{attachment_id}) to PDF failed on retry #{retry_count.to_i} with error \"#{e.message}\""
  end

private

  def should_warn?
    retry_count == (MAX_RETRIES / 2) + 1
  end
end
