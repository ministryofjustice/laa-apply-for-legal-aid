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

      individuals = [@legal_aid_application.applicant]
      individuals << @legal_aid_application.partner if check_partner?

      USE_CASES.each do |use_case|
        individuals.each do |person|
          hmrc_response = person.hmrc_responses.create!(use_case:, legal_aid_application: @legal_aid_application)
          if use_mock?
            MockInterfaceResponseService.call(hmrc_response)
          else
            HMRC::SubmissionWorker.perform_async(hmrc_response.id)
          end
        end
      end
    end

  private

    def use_mock?
      Rails.configuration.x.hmrc_use_dev_mock && HostEnv.not_production?
    end

    def check_partner?
      @legal_aid_application.applicant.has_partner_with_no_contrary_interest? &&
        @legal_aid_application.partner.has_national_insurance_number?
    end
  end
end
