module Providers
  module Means
    class IdentifyTypesOfOutgoingsController < ProviderBaseController
      def show
        @none_selected = legal_aid_application.no_debit_transaction_types_selected?
      end

      def update
        if outgoings_types.save
          continue_or_draft
        else
          legal_aid_application.errors.add :transaction_type_ids, t(".none_selected")
          render :show
        end
      end

    private

      def outgoings_types
        OutgoingsTypesUpdater.new(params)
      end
    end
  end
end
