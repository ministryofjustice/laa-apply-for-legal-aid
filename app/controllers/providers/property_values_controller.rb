module Providers
  class PropertyValuesController < BaseController
    def show
      @form = LegalAidApplications::PropertyValueForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PropertyValueForm.new(edit_params)

      if @form.save
        if legal_aid_application.own_home == 'mortgage'
          render plain: 'Navigate to question 1c: Mortgage'
          # redirect_to question_1c_path
        else
          render plain: 'Navigate to question 1d: Shared?'
          # redirect_to question_1d_path
        end
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
      @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
    end
  end
end
