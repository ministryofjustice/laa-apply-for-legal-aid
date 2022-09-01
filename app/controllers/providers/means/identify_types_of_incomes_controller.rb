module Providers
  module Means
    class IdentifyTypesOfIncomesController < ProviderBaseController
      def show
        @none_selected = legal_aid_application.no_credit_transaction_types_selected?
      end

      def update
        if income_types.save
          continue_or_draft
        else
          legal_aid_application.errors.add :transaction_type_ids, t(".none_selected")
          render :show
        end
      end

    private

      def income_types
        IncomeTypesUpdater.new(params)
      end
    end
  end
end
