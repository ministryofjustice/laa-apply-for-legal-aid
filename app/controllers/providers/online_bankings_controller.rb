module Providers
  class OnlineBankingsController < ProviderBaseController
    include ApplicationDependable
    include Flowable
    include Draftable

    def show
      authorize @legal_aid_application
      @form = Applicants::UsesOnlineBankingForm.new(model: applicant)
    end

    def update
      authorize @legal_aid_application
      @form = Applicants::UsesOnlineBankingForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def applicant_params
      params.permit(applicant: :uses_online_banking)[:applicant] || {}
    end

    def form_params
      applicant_params.merge(model: applicant)
    end
  end
end
