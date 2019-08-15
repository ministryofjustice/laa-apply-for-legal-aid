module Providers
  class OnlineBankingsController < ProviderBaseController
    def show
      @form = Applicants::UsesOnlineBankingForm.new(model: applicant)
    end

    def update
      @form = Applicants::UsesOnlineBankingForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

    private

    def form_params
      merge_with_model(applicant) do
        params.permit(applicant: :uses_online_banking)[:applicant] || {}
      end
    end
  end
end
