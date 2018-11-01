module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    before_action :set_current_step

    def index
      create_benefit_check unless legal_aid_application.benefit_check_result
      @next_step_link = action_for_next_step(options: { application: legal_aid_application })
    end

    private

    def create_benefit_check
      legal_aid_application.create_benefit_check_result!(
        result: benefit_check_response.dig(:benefit_checker_status),
        dwp_ref: benefit_check_response.dig(:confirmation_ref)
      )
    end

    def benefit_check_response
      @benefit_check_response ||= BenefitCheckService.new(legal_aid_application).check_benefits
    end

    def set_current_step
      @current_step = :check_benefits
    end
  end
end
