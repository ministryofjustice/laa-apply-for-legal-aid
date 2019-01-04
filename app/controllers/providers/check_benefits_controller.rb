module Providers
  class CheckBenefitsController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def index
      legal_aid_application.add_benefit_check_result if legal_aid_application.benefit_check_result_needs_updating?
    end

    def update
      continue_or_save_draft
    end

    private

    def next_step_url
      if legal_aid_application.benefit_check_result.positive?
        providers_legal_aid_application_own_home_path(legal_aid_application)
      else
        providers_legal_aid_application_online_banking_path(legal_aid_application)
      end
    end
  end
end
