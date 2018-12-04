module Providers
  class CheckBenefitsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def index
      legal_aid_application.add_benefit_check_result if legal_aid_application.benefit_check_result_needs_updating?
      next_step
    end

    private

    def next_step
      return @next_step_link = submit_providers_legal_aid_application_about_the_financial_assessment_path(@legal_aid_application) if legal_aid_application.benefit_check_result.positive?
      @next_step_link = providers_legal_aid_application_about_the_financial_assessment_path
    end
  end
end
