module CCMS
  class SubmissionStateUnchanged < StandardError; end

  class SentryIgnoreThisSidekiqFailError < StandardError; end

  class SubmissionProcessWorker
    include Sidekiq::Worker
    include Sidekiq::Status::Worker

    attr_accessor :retry_count, :submission

    MAX_RETRIES = 10
    sidekiq_options retry: MAX_RETRIES
    sidekiq_retries_exhausted do |msg, _ex|
      Sentry.capture_message Sidekiq::ExhaustedFailureMessage.call(msg)
    end

    def perform(submission_id, start_state)
      @submission = Submission.find(submission_id)
      Sentry.capture_message in_progress_error if should_warn?

      @submission.process!

      return if @submission.completed?

      # raise an error if the current attempt has not changed the state
      raise SubmissionStateUnchanged if state_unchanged?(start_state)

      # if state has changed then create new worker for next state and successfully exit!
      SubmissionProcessWorker.perform_async(submission_id, @submission.aasm_state)
    rescue StandardError => e
      raise if @retry_count.eql? MAX_RETRIES

      raise SentryIgnoreThisSidekiqFailError, "Submission `#{@submission.id}` failed at `#{start_state}` on retry #{@retry_count.to_i} with error #{e.message}"
    end

  private

    def should_warn?
      @retry_count == (MAX_RETRIES / 2) + 1
    end

    def state_unchanged?(start_state)
      @submission.aasm_state == start_state
    end

    def in_progress_error
      <<~ERROR
        CCMS submission id: #{@submission.id} is failing
        #{job_stuck}
      ERROR
    end

    def job_stuck
      "job stuck at state: #{@submission.aasm_state} with retry count at #{@retry_count}"
    end
  end
end
