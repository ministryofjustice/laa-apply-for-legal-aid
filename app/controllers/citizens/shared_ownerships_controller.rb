module Citizens
  class SharedOwnershipsController < BaseController
    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params.merge(model: legal_aid_application))

      if @form.save
        if @form.model.shared_ownership?
          render plain: 'Navigate to question 1e; What percentage of your home do you own?'
        else
          render plain: 'Navigate to question 2a; Do you have any savings or investments'
        end
      else
        render :show
      end
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end

    def shared_ownership_params
      params.require(:legal_aid_application).permit(:shared_ownership)
    end
  end
end
