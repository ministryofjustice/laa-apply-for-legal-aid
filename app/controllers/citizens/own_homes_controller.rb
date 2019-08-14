module Citizens
  class OwnHomesController < CitizenBaseController
    def show
      @form = LegalAidApplications::OwnHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OwnHomeForm.new(form_params)

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def form_params
      merge_with_model(legal_aid_application) do
        return {} unless params[:legal_aid_application]

        params.require(:legal_aid_application).permit(:own_home)
      end
    end
  end
end
