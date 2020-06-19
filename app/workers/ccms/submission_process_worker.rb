module CCMS
  class SubmissionProcessWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    def perform(submission_id, state)
      submission = Submission.find(submission_id)
      return unless submission.aasm_state == state.to_s # skip if state has already changed

      submission.process!
      return if submission.completed? || submission.failed?

      # process next step
      SubmissionProcessWorker.perform_in(submission.delay, submission.id, submission.aasm_state)
    end
  end
end
