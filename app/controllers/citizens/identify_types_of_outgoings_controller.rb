module Citizens
  class IdentifyTypesOfOutgoingsController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def show
      legal_aid_application
    end

    def update
      return go_forward if none_selected? || transactions_added

      legal_aid_application.errors.add :base, t('.none_selected')
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
      params[:none_selected] == 'true' && remove_existing_transaction_types
    end

    def transactions_added
      return if transaction_types.empty?

      remove_existing_transaction_types
      legal_aid_application.transaction_types << transaction_types
    end

    def remove_existing_transaction_types
      legal_aid_application.legal_aid_application_transaction_types.debits.destroy_all
    end
  end
end
