# :nocov:
module Citizens
  class SharedOwnershipsController < CitizenBaseController
    def show
      @form = LegalAidApplications::SharedOwnershipForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::SharedOwnershipForm.new(shared_ownership_params)

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def shared_ownership_params
      merge_with_model(legal_aid_application, journey: :citizens) do
        next {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:shared_ownership)
      end
    end
  end
end
# :nocov:
