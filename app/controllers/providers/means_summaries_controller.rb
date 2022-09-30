module Providers
  class MeansSummariesController < ProviderBaseController
    def show
      legal_aid_application.set_transaction_period
      legal_aid_application.check_non_passported_means! unless legal_aid_application.checking_non_passported_means?
    end

    def update
      if cfe_call_required?
        redirect_to(problem_index_path) && return unless check_financial_eligibility

        legal_aid_application.provider_enter_merits!
      end
      continue_or_draft
    end

  private

    # TODO: if show is always called before update and converts
    # state to `checking_non_passported_means` then I do not see
    # how legal_aid_application.provider_entering_merits? can ever be true!
    #
    def cfe_call_required?
      return false if draft_selected? || legal_aid_application.provider_entering_merits?
      return false if legal_aid_application.uploading_bank_statements? && !legal_aid_application.using_enhanced_bank_upload?

      true
    end

    def check_financial_eligibility
      CFE::SubmissionManager.call(legal_aid_application.id)
    end
  end
end
