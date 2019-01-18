module Citizens
  class PropertyValuesController < ApplicationController
    include Flowable

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
