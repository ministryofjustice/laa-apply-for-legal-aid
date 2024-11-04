module Providers
  module Means
    class CheckIncomeAnswersController < ProviderBaseController
      before_action :set_transaction_types, only: :show

      def show
        legal_aid_application.check_means_income! unless legal_aid_application.checking_means_income?
        legal_aid_application.set_transaction_period
      end

      def update
        legal_aid_application.provider_assess_means!
        continue_or_draft
      end

    private

      def set_transaction_types
        @credit_transaction_types = if legal_aid_application.client_uploading_bank_statements?
                                      TransactionType.credits.without_disregarded_benefits.without_benefits
                                    else
                                      TransactionType.credits.without_housing_benefits
                                    end

        @debit_transaction_types = TransactionType.debits
      end
    end
  end
end
