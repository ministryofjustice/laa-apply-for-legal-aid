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
        legal_aid_application.provider_assess_means!
        continue_or_draft
      end
    end
  end
end
