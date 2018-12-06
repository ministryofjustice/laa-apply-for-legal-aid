module Citizens
  class PropertyValuesController < BaseController
    def show
      # @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
      @form = Applicants::PropertyValueForm.new # this is so errors are visible
    end

    def create
      # @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
      @form = Applicants::PropertyValueForm.new(edit_params)

      if @form.save
        render plain: 'Navigate to question 1c; What is the outstanding mortgage?'
      else
        # @legal_aid_application = LegalAidApplication.find(session[:current_application_ref])
        render :show
      end
    end

    private

    # def current_params
    #   current_applicant.legal_aid_application.attributes.symbolize_keys.slice(:property_value)
    # end

    # def current_params
    #   return unless current_applicant.legal_aid_application.property_value
    #   applicant.property_value.attributes.symbolize_keys.slice(:property_value)
    # end

    def property_value_params
      params.fetch(:legal_aid_application, {}).permit(:property_value)
    end

    def edit_params
      property_value_params.merge(model: current_applicant.legal_aid_application)
    end
  end
end
