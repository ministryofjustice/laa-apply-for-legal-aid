module HMRC
  class ResultWorker < BaseWorker
    def perform(hmrc_response_id)
      super do
        response = HMRC::Interface::ResultService.call(@hmrc_response)
        raise SentryIgnoreThisSidekiqFailError, 'HMRC Submission still in progress, fail silently and re-try' if response[:status].eql?('in_progress')

        @hmrc_response.update(response: response)
      end
    end

    private

    def in_progress_error
      <<~ERROR
        HMRC result check for id: #{@hmrc_response.id} is failing, retry count at #{@retry_count}
      ERROR
    end
  end
end
