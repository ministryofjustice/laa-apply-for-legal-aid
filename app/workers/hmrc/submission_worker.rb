module HMRC
  class SubmissionWorker < BaseWorker
    def perform(hmrc_response_id)
      super do
        response = HMRC::Interface::SubmissionService.call(@hmrc_response)
        HMRC::ResultWorker.perform_in(5.seconds, hmrc_response_id) if response.keys == %i[id _links]
      end
    end

    private

    def in_progress_error
      <<~ERROR
        HMRC submission id: #{@hmrc_response.id} is failing, retry count at #{@retry_count}
      ERROR
    end
  end
end
