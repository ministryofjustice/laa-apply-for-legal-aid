# :nocov:
module Citizens
  class PropertyValuesController < CitizenBaseController
    def show
      @form = LegalAidApplications::PropertyValueForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PropertyValueForm.new(edit_params)

      if @form.save
        go_forward
      else
        render :show
      end
    end

    private

    def edit_params
      merge_with_model(legal_aid_application) do
        params.require(:legal_aid_application).permit(:property_value)
      end
    end
  end
end
# :nocov:
