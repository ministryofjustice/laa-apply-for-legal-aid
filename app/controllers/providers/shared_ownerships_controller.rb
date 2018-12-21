module Providers
  class SharedOwnershipsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable
    include SaveAsDraftable

    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params.merge(model: legal_aid_application))

      if @form.save
        if @form.shared_ownership?
          continue_or_save_draft(providers_legal_aid_application_percentage_home_path(legal_aid_application))
        else
          continue_or_save_draft(providers_legal_aid_application_savings_and_investment_path(legal_aid_application))
        end
      else
        render :show
      end
    end

    private

    def shared_ownership_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:shared_ownership)
    end
  end
end
