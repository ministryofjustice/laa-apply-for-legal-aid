module Citizens
  class IdentifyTypesOfOutgoingsController < CitizenBaseController
    def show
      legal_aid_application
      @none_selected = legal_aid_application.no_debit_transaction_types_selected?
    end

    def update
      return go_forward if none_selected? || transactions_added

      remove_existing_transaction_types
      legal_aid_application.errors.add :transaction_type_ids, t('.none_selected')
      render :show
    end

    private

    def legal_aid_application_params
      params.require(:legal_aid_application).permit(transaction_type_ids: [])
    end

    def transaction_types
      TransactionType.debits.where(id: legal_aid_application_params[:transaction_type_ids])
    end

    def none_selected?
      return unless params[:legal_aid_application][:none_selected] == 'true'

      LegalAidApplication.transaction do
        remove_existing_transaction_types
        legal_aid_application.update!(no_debit_transaction_types_selected: true)
      end
    end

    def transactions_added
      return if transaction_types.empty?

      LegalAidApplication.transaction do
        remove_existing_transaction_types
        legal_aid_application.update!(no_debit_transaction_types_selected: false)
        legal_aid_application.transaction_types << transaction_types
      end
    end

    def remove_existing_transaction_types
      legal_aid_application.legal_aid_application_transaction_types.debits.destroy_all
    end
  end
end
