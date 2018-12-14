module Citizens
  class PropertyValuesController < BaseController
    def show
      @form = LegalAidApplications::PropertyValueForm.new(model: legal_aid_application)
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
      property_value_params.merge(model: legal_aid_application)
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(session[:current_application_ref])
    end
  end
end
