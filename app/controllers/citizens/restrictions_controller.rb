module Citizens
  class RestrictionsController < CitizenBaseController
    def show
      @form = LegalAidApplications::RestrictionsForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::RestrictionsForm.new(form_params)
      return go_forward if @form.save

      render :show
    end

    private

    def form_params
      merge_with_model(legal_aid_application, journey: :citizens) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:has_restrictions, :restrictions_details)
      end
    end
  end
end
