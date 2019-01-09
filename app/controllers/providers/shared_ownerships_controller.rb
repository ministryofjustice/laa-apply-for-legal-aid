module Providers
  class SharedOwnershipsController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params.merge(model: legal_aid_application))

      if @form.save
        continue_or_save_draft(continue_url: next_url)
      else
        render :show
      end
    end

    private

    def back_step_url
      if legal_aid_application.own_home_mortgage?
        providers_legal_aid_application_outstanding_mortgage_path
      else
        providers_legal_aid_application_property_value_path
      end
    end

    def next_url
      if @form.shared_ownership?
        providers_legal_aid_application_percentage_home_path(legal_aid_application)
      else
        providers_legal_aid_application_savings_and_investment_path(legal_aid_application)
      end
    end

    def shared_ownership_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:shared_ownership)
    end
  end
end
