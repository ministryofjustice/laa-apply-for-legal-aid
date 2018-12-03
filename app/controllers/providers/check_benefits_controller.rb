module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def index
      legal_aid_application.add_benefit_check_result if legal_aid_application.benefit_check_result_needs_updating?

      @back_step_url = back_step_path

      next_step
    end

    private

    def back_step_path
      return providers_legal_aid_application_address_selection_path if applicant.address&.lookup_used?

      providers_legal_aid_application_address_path
    end

    def next_step
      # TODO: implement next_step logic. Next step depends on the result of the benefit_check.
      @next_step_link = next_step_url
    end
  end
end
