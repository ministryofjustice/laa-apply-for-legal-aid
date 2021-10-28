module HMRC
  class SubmissionWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker
    attr_accessor :retry_count

    MAX_RETRIES = 10
    sidekiq_options retry: MAX_RETRIES
    sidekiq_retries_exhausted do |msg, _ex|
      Sentry.capture_message <<~ERROR
        HMRC submission id: #{msg['args'].first} failed
        Moving #{msg['class']} to dead set, it failed with: #{msg['error_class']}/#{msg['error_message']}
      ERROR
    end

    def perform(hmrc_response_id)
      @hmrc_response = HMRC::Response.find(hmrc_response_id)
      Sentry.capture_message in_progress_error if should_warn?

      response = HMRC::Interface::SubmissionService.call(@hmrc_response)
      HMRC::ResultWorker.perform_in(5.seconds, hmrc_response_id) if response.keys == %i[id _links]
    rescue StandardError => e
      raise if @retry_count.eql? MAX_RETRIES

      raise SentryIgnoreThisSidekiqFailError, "HMRC submission for `#{@hmrc_response.legal_aid_application.id}` failed on retry #{@retry_count.to_i} with error #{e.message}"
    end

    private

    def should_warn?
      @retry_count == (MAX_RETRIES / 2) + 1
    end

    def in_progress_error
      <<~ERROR
        HMRC submission id: #{@hmrc_response.id} is failing, retry count at #{@retry_count}
      ERROR
    end
  end
end
