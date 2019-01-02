module Providers
  class PropertyValuesController < BaseController
    include Steppable
    include SaveAsDraftable

    def show
      @form = LegalAidApplications::PropertyValueForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PropertyValueForm.new(edit_params)

      if @form.save
        continue_or_save_draft(continue_url: next_url)
      else
        render :show
      end
    end

    private

    def next_url
      if legal_aid_application.own_home_mortgage?
        providers_legal_aid_application_outstanding_mortgage_path(legal_aid_application)
      else
        providers_legal_aid_application_shared_ownership_path(legal_aid_application)
      end
    end

    def property_value_params
      params.require(:legal_aid_application).permit(:property_value)
    end

    def edit_params
      property_value_params.merge(model: legal_aid_application, mode: :provider)
    end

    def legal_aid_application
      @legal_aid_application ||= LegalAidApplication.find(params[:legal_aid_application_id])
    end
  end
end
