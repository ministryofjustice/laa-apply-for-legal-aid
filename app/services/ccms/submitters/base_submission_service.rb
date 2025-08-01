module CCMS
  require Rails.root.join("app/services/faraday/soap_call.rb")
  CCMS_SUBMISSION_ERRORS = [
    CCMSError,
    CCMSUnsuccessfulResponseError,
    Faraday::Error,
    Faraday::SoapError,
    StandardError,
  ].freeze

  module Submitters
    class BaseSubmissionService
      include MessageLogger
      attr_accessor :submission

      def initialize(submission)
        @submission = submission
      end

      def self.call(*)
        new(*).call
      end

    private

      def create_history(from_state, to_state, xml_request, xml_response)
        SubmissionHistory.create submission:,
                                 from_state:,
                                 to_state:,
                                 success: true,
                                 request: xml_request,
                                 response: xml_response
      end

      def create_ccms_failure_history(from_state, error, xml_request, response: nil)
        SubmissionHistory.create submission:,
                                 from_state:,
                                 to_state: :failed,
                                 success: false,
                                 request: xml_request,
                                 details: error.is_a?(Exception) ? format_exception(error) : error,
                                 response:
      end

      def format_exception(error)
        [error.class, error.message, error.backtrace].join("\n")
      end

      def handle_exception(exception, xml_request, response: nil)
        create_ccms_failure_history(submission.aasm_state, exception, xml_request, response:)
      end
    end
  end
end
