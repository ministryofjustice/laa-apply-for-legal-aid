module Providers
  module Means
    class CheckIncomeAnswersController < ProviderBaseController
      include TransactionTypeSettable

      helper_method :display_employment_income?

      def show
        legal_aid_application.check_means_income! unless legal_aid_application.checking_means_income?
        legal_aid_application.set_transaction_period
      end

      def update
        if cfe_call_required? && !check_financial_eligibility
          redirect_to(problem_index_path) && return

        end

        legal_aid_application.provider_assess_means!
        continue_or_draft
      end

    private

      def cfe_call_required?
        return false if draft_selected? || !legal_aid_application.return_to_review_and_print

        true
      end

      def check_financial_eligibility
        CFECivil::SubmissionBuilder.call(@legal_aid_application)
      end
    end
  end
end
