module Providers
  class CheckBenefitsController < ProviderBaseController
    def index
      legal_aid_application.add_benefit_check_result if legal_aid_application.benefit_check_result_needs_updating?
    end

    def update
      continue_or_draft
    end
  end
end
