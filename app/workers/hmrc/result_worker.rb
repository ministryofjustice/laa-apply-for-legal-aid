module HMRC
  class ResultWorker < BaseWorker
    def perform(hmrc_response_id)
      super do
        response = HMRC::Interface::ResultService.call(@hmrc_response)
        raise SentryIgnoreThisSidekiqFailError, "HMRC Submission still in progress, fail silently and re-try" if %w[created processing].include?(response[:status])

        @hmrc_response.update!(response:)
      end
    end
  end
end
