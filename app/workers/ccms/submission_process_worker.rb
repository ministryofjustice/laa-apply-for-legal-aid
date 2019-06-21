module CCMS
  class SubmissionProcessWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform(submission_id, state)
      submission = Submission.find(submission_id)
      submission.process! if submission.aasm_state == state.to_s # skip if state has already changed
    end
  end
end
