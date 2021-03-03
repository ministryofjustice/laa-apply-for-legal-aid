module CCMS
  module Submitters
    class BaseSubmissionService
      attr_accessor :submission

      CCMS_SUBMISSION_ERRORS = [
        CCMSError,
        Savon::HTTPError,
        Savon::SOAPFault,
        Savon::Error,
        StandardError
      ].freeze

      def initialize(submission)
        @submission = submission
      end

      def self.call(*args)
        new(*args).call
      end

      private

      def create_history(from_state, to_state, xml_request, xml_response)
        SubmissionHistory.create submission: submission,
                                 from_state: from_state,
                                 to_state: to_state,
                                 success: true,
                                 request: xml_request,
                                 response: xml_response
      end

      def create_failure_history(from_state, error, xml_request, xml_response)
        SubmissionHistory.create submission: submission,
                                 from_state: from_state,
                                 to_state: :failed,
                                 success: false,
                                 details: error,
                                 request: xml_request,
                                 response: xml_response
      end

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

      def handle_unsuccessful_response(xml_request, xml_response)
        Sentry.capture_exception(xml_response)
        create_failure_history(submission.aasm_state, nil, xml_request, xml_response)
        submission.fail! unless submission.failed?
      end

      def handle_exception(exception, xml_request)
        Sentry.capture_exception(exception)
        create_ccms_failure_history(submission.aasm_state, exception, xml_request)
        submission.fail! unless submission.failed?
      end
    end
  end
end
