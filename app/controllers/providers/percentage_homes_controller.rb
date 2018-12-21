module Providers
  class PercentageHomesController < BaseController
    include Providers::ApplicationDependable
    include Providers::Steppable
    include SaveAsDraftable

    def show
      @form = LegalAidApplications::PercentageHomeForm.new(model: legal_aid_application)
    end

    def update
      @form = LegalAidApplications::PercentageHomeForm.new(percentage_home_params.merge(model: legal_aid_application))

      if @form.save
        continue_or_save_draft
      else
        render :show
      end
    end

    private

    def percentage_home_params
      return {} unless params[:legal_aid_application]

      params.require(:legal_aid_application).permit(:percentage_home)
    end
  end
end
