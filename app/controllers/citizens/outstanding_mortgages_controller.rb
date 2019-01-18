module Citizens
  class OutstandingMortgagesController < ApplicationController
    include Flowable
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
      params.require(:legal_aid_application).permit(:outstanding_mortgage_amount).tap do |hash|
        hash[:model] = legal_aid_application
      end
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
