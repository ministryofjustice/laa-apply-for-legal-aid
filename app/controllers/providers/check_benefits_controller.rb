module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    before_action :set_current_step

    def index
      legal_aid_application.add_benefit_check_result unless legal_aid_application.benefit_check_result

      next_step
    end

    private

    def next_step
      # TODO: implement next_step logic. Next step depends on the result of the benefit_check.
      @next_step_link = action_for_next_step(options: { application: legal_aid_application })
    end

    def set_current_step
      @current_step = :check_benefits
    end
  end
end
