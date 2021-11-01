module HMRC
  class ResultWorker < BaseWorker
    def perform(hmrc_response_id)
      super do
        response = HMRC::Interface::ResultService.call(@hmrc_response)
        raise SentryIgnoreThisSidekiqFailError, 'HMRC Submission still in progress, fail silently and re-try' if response[:status].eql?('in_progress')

        @hmrc_response.update(response: response)
      end
    end
  end
end
