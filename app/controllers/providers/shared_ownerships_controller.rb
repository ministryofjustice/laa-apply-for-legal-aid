module Providers
  class SharedOwnershipsController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable

    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params.merge(model: legal_aid_application))

      if @form.save
        if @form.shared_ownership?
          render plain: 'Navigate to question 1e; What percentage of your home do you own?'
        else
          render plain: 'Navigate to question 2a; Do you have any savings or investments'
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
