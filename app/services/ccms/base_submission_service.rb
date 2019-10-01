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

    def create_history(from_state, to_state, xml_request)
      SubmissionHistory.create submission: submission,
                               from_state: from_state,
                               to_state: to_state,
                               success: true,
                               request: xml_request  #database field is 'request'
    end

    def create_failure_history(from_state, error, xml_request)
      SubmissionHistory.create submission: submission,
                               from_state: from_state,
                               to_state: :failed,
                               success: false,
                               details: error.is_a?(Exception) ? format_exception(error) : error,
                               request: xml_request
    end

    # # TODO:
    # As it currently stands the method below is not required, it duplicates the create_failure_history method above,
    # It is left in for now as it may be required when the xml_response needs to be saved
    # the xml_response will not exist for ccms failure records so they will diverge at that stage
    def create_ccms_failure_history(from_state, error, xml_request)
      SubmissionHistory.create submission: submission,
                               from_state: from_state,
                               to_state: :failed,
                               success: false,
                               request: xml_request,
                               details: error.is_a?(Exception) ? format_exception(error) : error
    end

    def format_exception(error)
      [error.class, error.message, error.backtrace].flatten.join("\n")
    end

    def handle_failure(error, xml_request)
      create_failure_history(submission.aasm_state, error, xml_request)
      submission.fail!
    end
    # # TODO:
    # See note above about duplication
    def handle_ccms_failure(error, xml_request)
      create_ccms_failure_history(submission.aasm_state, error, xml_request)
      submission.fail!
    end
  end
end
