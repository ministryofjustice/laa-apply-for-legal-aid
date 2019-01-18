module Providers
  class OutstandingMortgagesController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def show
      @form = LegalAidApplications::OutstandingMortgageForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OutstandingMortgageForm.new(legal_aid_application_params)

      if @form.save
        continue_or_save_draft
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
