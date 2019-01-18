module Providers
  class OwnHomesController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def show
      authorize @legal_aid_application
      @form = LegalAidApplications::OwnHomeForm.new(model: legal_aid_application)
    end

    def update
      authorize @legal_aid_application
      @form = LegalAidApplications::OwnHomeForm.new(form_params)
      if @form.save
        continue_or_save_draft(continue_url: next_url)
      else
        render :show
      end
    end

    private

    def next_url
      if @form.own_home_no?
        providers_legal_aid_application_savings_and_investment_path(legal_aid_application)
      else
        providers_legal_aid_application_property_value_path(legal_aid_application)
      end
    end

    def own_home_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:own_home)
    end

    def form_params
      own_home_params.merge(model: legal_aid_application)
    end
  end
end
