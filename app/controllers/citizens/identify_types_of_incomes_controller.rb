module Citizens
  class IdentifyTypesOfIncomesController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def show
      legal_aid_application
    end

    def update
      legal_aid_application.update!(legal_aid_application_params)
      go_forward
    end

    private

    def legal_aid_application_params
      params.require(:legal_aid_application).permit(transaction_type_ids: [])
    end
  end
end
