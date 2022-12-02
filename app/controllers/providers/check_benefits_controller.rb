module Providers
  class CheckBenefitsController < ProviderBaseController
    include PreDWPCheckVisible
    include ApplicantDetailsCheckable
    include BenefitCheckSkippable

    helper_method :should_use_ccms?

    def index
      details_checked! unless details_checked? || legal_aid_application.non_passported?
      @applicant = legal_aid_application.applicant
      return skip_benefit_check_and_go_forward! if known_issue_prevents_benefit_check?

      check_benefits && return if legal_aid_application.benefit_check_result_needs_updating?

      go_forward(true) if legal_aid_application.non_passported?
    end

    def update
      continue_or_draft
    end

  private

    def check_benefits
      redirect_to problem_index_path unless legal_aid_application.add_benefit_check_result
    end

    def should_use_ccms?
      UseCCMSArbiter.call(legal_aid_application)
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
