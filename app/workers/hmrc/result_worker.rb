module HMRC
  class ResultWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker
    attr_accessor :retry_count

    MAX_RETRIES = 10
    sidekiq_options retry: MAX_RETRIES
    sidekiq_retries_exhausted do |msg, _ex|
      Sentry.capture_message <<~ERROR
        HMRC result check for id: #{msg['args'].first} failed
        Moving #{msg['class']} to dead set, it failed with: #{msg['error_class']}/#{msg['error_message']}
      ERROR
    end

    def perform(hmrc_response_id)
      @hmrc_response = HMRC::Response.find(hmrc_response_id)
      Sentry.capture_message in_progress_error if should_warn?

      response = HMRC::Interface::ResultService.call(@hmrc_response)
      raise SentryIgnoreThisSidekiqFailError, 'HMRC Submission still in progress, fail silently and re-try' if response[:status].eql?('in_progress')

      @hmrc_response.update(response: response)
    rescue StandardError => e
      raise if @retry_count.eql? MAX_RETRIES

      raise SentryIgnoreThisSidekiqFailError, "HMRC result check for `#{@hmrc_response.legal_aid_application.id}` failed on retry #{@retry_count.to_i} with error #{e.message}"
    end

    private

    def should_warn?
      @retry_count == (MAX_RETRIES / 2) + 1
    end

    def in_progress_error
      <<~ERROR
        HMRC result check for id: #{@hmrc_response.id} is failing, retry count at #{@retry_count}
      ERROR
    end
  end
end
