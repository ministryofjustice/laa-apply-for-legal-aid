module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    before_action :set_current_step

    def index
      create_benefit_check unless legal_aid_application.benefit_check_result
      @next_step_link = action_for_next_step(options: {application: legal_aid_application})
    end

    def create_benefit_check
      response = BenefitCheckService.new(legal_aid_application).check_benefits
      status = response.dig(:benefit_checker_status)
      reference = response.dig(:confirmation_ref)

      legal_aid_application.create_benefit_check_result!(result: status, dwp_ref: reference)
    end

    private

    def set_current_step
      @current_step = :check_benefits
    end
  end
end
