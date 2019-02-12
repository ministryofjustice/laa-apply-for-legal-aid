module Providers
  class PropertyValuesController < BaseController
    include ApplicationDependable
    include Flowable
    include Draftable

    def show
      @form = LegalAidApplications::PropertyValueForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PropertyValueForm.new(edit_params)

      render :show unless save_continue_or_draft(@form)
    end

    private

    def property_value_params
      params.require(:legal_aid_application).permit(:property_value)
    end

    def edit_params
      property_value_params.merge(model: legal_aid_application, mode: :provider)
    end
  end
end
