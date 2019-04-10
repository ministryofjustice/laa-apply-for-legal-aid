module Citizens
  class IdentifyTypesOfIncomesController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def show
      legal_aid_application
    end

    def update
      legal_aid_application.transaction_types.credits.destroy_all
      legal_aid_application.transaction_types << transaction_types
      go_forward
    end

    private

    def legal_aid_application_params
      params.require(:legal_aid_application).permit(transaction_type_ids: [])
    end

    def transaction_types
      TransactionType.credits.where(id: legal_aid_application_params[:transaction_type_ids])
    end
  end
end
