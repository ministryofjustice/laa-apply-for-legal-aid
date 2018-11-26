module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def index
      legal_aid_application.add_benefit_check_result unless legal_aid_application.benefit_check_result

      next_step
    end

    private

    def next_step
      # TODO: implement next_step logic. Next step depends on the result of the benefit_check.
      @next_step_link = next_step_url
    end
  end
end
