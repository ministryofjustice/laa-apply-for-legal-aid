module HMRC
  class SubmissionWorker < BaseWorker
    def perform(hmrc_response_id)
      super do
        response = HMRC::Interface::SubmissionService.call(@hmrc_response)
        @hmrc_response.update!(url: response[:_links][0][:href], submission_id: response[:id])
        HMRC::ResultWorker.perform_in(5.seconds, hmrc_response_id) if response.keys == %i[id _links]
      end
    end
  end
end
