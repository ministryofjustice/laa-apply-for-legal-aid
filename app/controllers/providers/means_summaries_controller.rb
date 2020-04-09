module Providers
  class MeansSummariesController < ProviderBaseController
    def show
      legal_aid_application.set_transaction_period
      legal_aid_application.provider_check_citizens_means_answers! unless legal_aid_application.provider_checking_citizens_means_answers?
    end

    def update
      unless draft_selected? || legal_aid_application.provider_checked_citizens_means_answers?
        redirect_to(problem_index_path) && return unless check_financial_eligibility

        legal_aid_application.provider_checked_citizens_means_answers!
      end
      continue_or_draft
    end

    private

    def check_financial_eligibility
      CFE::SubmissionManager.call(legal_aid_application.id)
    end
  end
end
