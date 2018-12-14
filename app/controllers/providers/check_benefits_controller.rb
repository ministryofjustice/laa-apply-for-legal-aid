module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def index
      legal_aid_application.add_benefit_check_result if legal_aid_application.benefit_check_result_needs_updating?
      next_step
    end

    def passported
      render plain: 'Landing page: Next step in providers journey'
    end

    private

    def next_step
      return @next_step_link = passported_providers_legal_aid_application_check_benefits_path if legal_aid_application.benefit_check_result.positive?

      @next_step_link = providers_legal_aid_application_online_banking_path
    end
  end
end
