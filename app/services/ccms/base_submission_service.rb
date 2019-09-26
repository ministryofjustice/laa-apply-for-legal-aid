module CCMS
  class BaseSubmissionService
    attr_accessor :submission

    def initialize(submission)
      @submission = submission
    end

    def self.call(*args)
      new(*args).call
    end

    private

    def create_history(from_state, to_state, request)
      SubmissionHistory.create submission: submission,
                               from_state: from_state,
                               to_state: to_state,
                               success: true,
                               request: request#.formatted_xml
                               # response: response.doc
    end

    def create_failure_history(from_state, error, request)
      SubmissionHistory.create submission: submission,
                               from_state: from_state,
                               to_state: :failed,
                               success: false,
                               request: request,
                               details: error.is_a?(Exception) ? format_exception(error) : error
    end

    def format_exception(error)
      [error.class, error.message, error.backtrace].flatten.join("\n")
    end

    def handle_failure(error, request)
      create_failure_history(submission.aasm_state, error, request)
      submission.fail!
    end
  end
end
