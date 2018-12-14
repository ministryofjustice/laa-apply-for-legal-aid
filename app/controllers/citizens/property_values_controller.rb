module Citizens
  class PropertyValuesController < BaseController
    def show
      @form = LegalAidApplications::PropertyValueForm.new
    end

    def update
      @form = LegalAidApplications::PropertyValueForm.new(edit_params)

      if @form.save
        redirect_to citizens_outstanding_mortgage_path
      else
        render :show
      end
    end

    private

    def property_value_params
      params.require(:legal_aid_application).permit(:property_value)
    end

    def edit_params
      property_value_params.merge(model: current_applicant.legal_aid_application)
    end
  end
end
