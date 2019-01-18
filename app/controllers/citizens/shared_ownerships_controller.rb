module Citizens
  class SharedOwnershipsController < ApplicationController
    include Flowable

    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params.merge(model: legal_aid_application))

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end

    def shared_ownership_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:shared_ownership)
    end
  end
end
