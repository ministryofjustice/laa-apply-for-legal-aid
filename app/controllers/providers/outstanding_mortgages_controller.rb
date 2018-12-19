module Providers
  class OutstandingMortgagesController < BaseController
    def show
      @form = LegalAidApplications::OutstandingMortgageForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OutstandingMortgageForm.new(edit_params)

      if @form.save
        render plain: 'Landing page: 1d. Does your client share ownership of their home?'
        # redirect_to next_step_path
      else
        render :show
      end
    end

    private

    def outstanding_mortgage_params
      params.require(:legal_aid_application).permit(:outstanding_mortgage_amount)
    end

    def edit_params
      outstanding_mortgage_params.merge(model: legal_aid_application)
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
    end
  end
end
