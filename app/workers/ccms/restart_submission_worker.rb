module CCMS
  class RestartSubmissionWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform(application_id)
      LegalAidApplication.find(application_id).restart_submission!
    end
  end
end
