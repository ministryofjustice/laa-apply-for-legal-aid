module Providers
  class MeansSummariesController < ProviderBaseController
    # before_action :set_transaction_types, only: :show

    def show
      # legal_aid_application.set_transaction_period
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

      true
    end

    def check_financial_eligibility
      CFE::SubmissionManager.call(legal_aid_application.id)
    end

    # def set_transaction_types
    #   @credit_transaction_types = if legal_aid_application.uploading_bank_statements?
    #                                 TransactionType.credits.without_disregarded_benefits
    #                               else
    #                                 TransactionType.credits.without_housing_benefits
    #                               end
    #
    #   @debit_transaction_types = TransactionType.debits
    # end
  end
end
