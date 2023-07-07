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
      # return unless @legal_aid_application.hmrc_responses.empty?

      individuals = []
      individuals << @legal_aid_application.applicant
      if @legal_aid_application.applicant.has_partner?
        # not sure if we do need to check whether they have NI or not but have left it in for now
        individuals << @legal_aid_application.partner if @legal_aid_application.partner.has_national_insurance_number?
      end

      USE_CASES.each do |use_case|
        individuals.each do |person|
          hmrc_response = @legal_aid_application.hmrc_responses.create(use_case:, owner_id: person.id, owner_type: person.class)
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
      Rails.configuration.x.hmrc_use_dev_mock && not_production_environment?
    end

    def not_production_environment?
      !HostEnv.production?
    end
  end
end
