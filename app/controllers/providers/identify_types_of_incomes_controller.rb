module Providers
  class IdentifyTypesOfIncomesController < ProviderBaseController
    def show
      @none_selected = legal_aid_application.no_credit_transaction_types_selected?
    end

    def update
      return continue_or_draft if none_selected? || transactions_added || draft_selected?

      remove_existing_transaction_types
      legal_aid_application.errors.add :transaction_type_ids, t('.none_selected')
      render :show
    end

    private

    def legal_aid_application_params
      params.require(:legal_aid_application).permit(transaction_type_ids: [])
    end

    def transaction_types
      @transaction_types ||= TransactionType.credits.find_with_children(legal_aid_application_params[:transaction_type_ids])
    end

    def none_selected?
      return unless params[:legal_aid_application][:none_selected] == 'true'

      LegalAidApplication.transaction do
        remove_existing_transaction_types
        legal_aid_application.update!(no_credit_transaction_types_selected: true)
      end
    end

    def transactions_added
      return if transaction_types.empty?

      LegalAidApplication.transaction do
        remove_existing_transaction_types
        legal_aid_application.update!(no_credit_transaction_types_selected: false)
        legal_aid_application.transaction_types << transaction_types
      end
    end

    def remove_existing_transaction_types
      legal_aid_application.legal_aid_application_transaction_types.credits.destroy_all
    end
  end
end
