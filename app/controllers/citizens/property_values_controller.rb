module Citizens
  class PropertyValuesController < BaseController
    def show
      @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
      @form = Applicants::PropertyValueForm.new(current_params) # this is so errors works
    end

    def create
      @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
      @form = Applicants::PropertyValueForm.new(edit_params)

      if @form.save
        render plain: 'Navigate to question 1c; What is the outstanding mortgage?'
      else
        @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
        render :show
      end
    end

    private

    def current_params
      @legal_aid_application.attributes.symbolize_keys.slice(:property_value)
    end

    def property_value_params
      params.fetch(:legal_aid_application, {}).permit(:property_value)
    end

    def edit_params
      property_value_params.merge(model: @legal_aid_application)
    end
  end
end
