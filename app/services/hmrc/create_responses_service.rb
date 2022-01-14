module HMRC
  class CreateResponsesService
    USE_CASES = %w[one two].freeze

    def initialize(legal_aid_application)
      @legal_aid_application = legal_aid_application
      @legal_aid_application.set_transaction_period
    end

    def self.call(legal_aid_application)
      new(legal_aid_application).call
    end

    def call
      return unless @legal_aid_application.hmrc_responses.empty?

      USE_CASES.each do |use_case|
        hmrc_response = @legal_aid_application.hmrc_responses.create(use_case: use_case)
        if use_mock?
          MockInterfaceResponseService.call(hmrc_response)
        else
          HMRC::SubmissionWorker.perform_async(hmrc_response.id)
        end
      end
    end

    private

    def use_mock?
      Rails.configuration.x.hmrc_use_dev_mock && !Rails.env.production?
    end
  end
end
