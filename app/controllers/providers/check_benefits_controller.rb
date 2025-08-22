module Providers
  class CheckBenefitsController < ProviderBaseController
    include ApplicantDetailsCheckable
    include BenefitCheckSkippable

    def show
      details_checked! unless details_checked? || legal_aid_application.non_passported?
      @applicant = legal_aid_application.applicant
      return skip_benefit_check_and_go_forward! if known_issue_prevents_benefit_check?

      return redirect_to providers_legal_aid_application_dwp_result_path unless Setting.collect_dwp_data?

      check_benefits && return if legal_aid_application.benefit_check_result_needs_updating?

      go_forward(true) if legal_aid_application.non_passported?
    end

    def update
      continue_or_draft
    end

  private

    def check_benefits
      redirect_to providers_legal_aid_application_dwp_result_path unless legal_aid_application.add_benefit_check_result
    end

    def known_issue_prevents_benefit_check?
      applicant.last_name.length == 1
    end

    def skip_benefit_check_and_go_forward!
      mark_as_benefit_check_skipped!("known_issue")
      go_forward
    end
  end
end
