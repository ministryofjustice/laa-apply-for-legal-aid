module Providers
  class OutstandingMortgagesController < BaseController
    include ApplicationDependable
    include Flowable

    def show
      authorize @legal_aid_application
      @form = LegalAidApplications::OutstandingMortgageForm.new(model: legal_aid_application)
    end

    def update
      authorize @legal_aid_application
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
  end
end
