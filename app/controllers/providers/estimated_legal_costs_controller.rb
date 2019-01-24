module Providers
  class EstimatedLegalCostsController < BaseController
    include ApplicationDependable
    include Steppable
    include SaveAsDraftable

    before_action :authorize_legal_aid_application

    def show
      @form = MeritsAssessments::EstimatedLegalCostForm.new(model: merits_assessment)
    end

    def update
      @form = MeritsAssessments::EstimatedLegalCostForm.new(form_params.merge(model: merits_assessment))

      if @form.save
        if params.key?(:continue_button)
          render plain: 'Placeholder: Will navigate to question What are the prospects of success?'
          return
        end
        continue_or_save_draft
      else
        render :show
      end
    end

    private

    def form_params
      params.require(:merits_assessment).permit(:estimated_legal_cost)
    end

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end
  end
end
