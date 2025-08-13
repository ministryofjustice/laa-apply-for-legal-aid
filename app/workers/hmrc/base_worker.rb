module HMRC
  class BaseWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    attr_accessor :retry_count

    MAX_RETRIES = 10
    sidekiq_options retry: MAX_RETRIES
    sidekiq_retries_exhausted do |msg, _ex|
      Sentry.capture_message Sidekiq::ExhaustedFailureMessage.call(msg)
    end

    def perform(hmrc_response_id)
      @hmrc_response = HMRC::Response.find(hmrc_response_id)
      check_and_warn_if_needed

      yield
    rescue StandardError => e
      raise if @retry_count.eql? MAX_RETRIES

      raise SentryIgnoreThisSidekiqFailError, "HMRC result check for `#{@hmrc_response.legal_aid_application.id}` failed on retry #{@retry_count.to_i} with error #{e.message}"
    end

  private

    def check_and_warn_if_needed
      Sentry.capture_message Sidekiq::InProgressWarningMessage.call(self.class, @hmrc_response, @retry_count) if should_warn?
    end

    def should_warn?
      @retry_count == (MAX_RETRIES / 2) + 1
    end
  end
end
