module Citizens
  class OutstandingMortgagesController < BaseController
    include ApplicationFromSession
    before_action :authenticate_applicant!

    def show
      @form = LegalAidApplications::OutstandingMortgageForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OutstandingMortgageForm.new(legal_aid_application_params)
      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def legal_aid_application_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(:outstanding_mortgage_amount)
      end
    end
  end
end
