module Providers
  class CheckBenefitsController < ProviderBaseController
    include PreDWPCheckVisible

    helper_method :should_use_ccms?

    def index
      details_checked! unless details_checked? || dwp_override_non_passported?
      @applicant = legal_aid_application.applicant
      return set_negative_result_and_go_forward if known_issue_prevents_benefit_check?

      check_benefits if legal_aid_application.benefit_check_result_needs_updating?

      go_forward(true) if dwp_override_non_passported?
    end

    def update
      continue_or_draft
    end

    private

    def dwp_override_non_passported?
      Setting.override_dwp_results? && legal_aid_application.non_passported?
    end

    def details_checked!
      legal_aid_application.applicant_details_checked!
    end

    def details_checked?
      legal_aid_application.applicant_details_checked?
    end

    def check_benefits
      redirect_to problem_index_path unless legal_aid_application.add_benefit_check_result
    end

    def should_use_ccms?
      return false if legal_aid_application.applicant_receives_benefit? && provider.passported_permissions?

      return false if provider.non_passported_permissions?

      legal_aid_application.use_ccms!(:non_passported) unless legal_aid_application.use_ccms?
      true
    end

    def known_issue_prevents_benefit_check?
      applicant.last_name.length == 1
    end

    def set_negative_result_and_go_forward
      legal_aid_application.create_benefit_check_result!(result: 'skipped:known_issue')
      go_forward
    end

    def provider
      legal_aid_application.provider
    end
  end
end
