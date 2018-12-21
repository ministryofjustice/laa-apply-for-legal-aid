module Providers
  class OwnHomesController < ApplicationController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def show
      @form = LegalAidApplications::OwnHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::OwnHomeForm.new(form_params)

      if @form.save
        if @form.own_home_no?
          continue_or_save_draft(providers_legal_aid_application_savings_and_investment_path(legal_aid_application))
        else
          continue_or_save_draft(providers_legal_aid_application_property_value_path(legal_aid_application))
        end
      else
        render :show
      end
    end

    private

    def own_home_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:own_home)
    end

    def form_params
      own_home_params.merge(model: legal_aid_application)
    end
  end
end
