module Providers
  class PercentageHomesController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    def show
      authorize @legal_aid_application
      @form = LegalAidApplications::PercentageHomeForm.new(model: legal_aid_application)
    end

    def update
      authorize @legal_aid_application
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
