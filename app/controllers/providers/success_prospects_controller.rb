module Providers
  class SuccessProspectsController < BaseController
    include ApplicationDependable
    include Flowable
    include Draftable

    before_action :authorize_legal_aid_application

    def show
      @form = MeritsAssessments::SuccessProspectForm.new(model: merits_assessment)
    end

    def update
      @form = MeritsAssessments::SuccessProspectForm.new(form_params.merge(model: merits_assessment))

      render :show unless save_continue_or_draft(@form)
    end

    private

    def merits_assessment
      @merits_assessment ||= legal_aid_application.merits_assessment || legal_aid_application.build_merits_assessment
    end

    def authorize_legal_aid_application
      authorize @legal_aid_application
    end

    def form_params
      params.require(:merits_assessment).permit(:success_prospect, :success_prospect_details)
    end
  end
end
