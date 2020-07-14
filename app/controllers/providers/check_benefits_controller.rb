module Providers
  class CheckBenefitsController < ProviderBaseController
    helper_method :should_use_ccms?

    def index
      legal_aid_application.applicant_details_checked! unless legal_aid_application.applicant_details_checked?
      @applicant = legal_aid_application.applicant
      return set_negative_result_and_go_forward if known_issue_prevents_benefit_check?

      check_benefits if legal_aid_application.benefit_check_result_needs_updating?
    end

    def update
      continue_or_draft
    end

    private

    def check_benefits
      redirect_to problem_index_path unless legal_aid_application.add_benefit_check_result
    end

    def should_use_ccms?
      return false if legal_aid_application.applicant_receives_benefit?

      return false if Setting.allow_non_passported_route?

      legal_aid_application.use_ccms! unless legal_aid_application.use_ccms?
      true
    end

    def known_issue_prevents_benefit_check?
      applicant.last_name.length == 1
    end

    def set_negative_result_and_go_forward
      legal_aid_application.create_benefit_check_result!(result: 'skipped:known_issue')
      go_forward
    end
  end
end
