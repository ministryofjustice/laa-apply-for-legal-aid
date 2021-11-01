module HMRC
  class CreateResponsesService
    USE_CASES = %w[one two].freeze

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def call
      USE_CASES.each do |use_case|
        hmrc_response = @legal_aid_application.hmrc_responses.create(use_case: use_case)
        HMRC::SubmissionWorker.perform_async(hmrc_response.id)
      end
    end
  end
end
