module Providers
  class PreviousReferencesController < ProviderBaseController
    reviewed_by :legal_aid_application, :check_provider_answers

    def show
      @form = Applicants::PreviousReferenceForm.new(model: applicant)
    end

    def update
      @form = Applicants::PreviousReferenceForm.new(form_params)
      render :show unless save_continue_or_draft(@form)
    end

  private

    def form_params
      merge_with_model(applicant) do
        params.expect(applicant: %i[applied_previously previous_reference])
      end
    end
  end
end
