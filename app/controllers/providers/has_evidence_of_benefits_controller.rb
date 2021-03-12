module Providers
  class HasEvidenceOfBenefitsController < ProviderBaseController
    def show
      @form = LegalAidApplications::HasEvidenceOfBenefitForm.new(model: dwp_override)

      @passporting_benefit = I18n.t(dwp_override.passporting_benefit)
    end

    def update
      @form = LegalAidApplications::HasEvidenceOfBenefitForm.new(form_params)
      update_state_machine_type
      render :show unless save_continue_or_draft(@form)
    end

    private

    def update_state_machine_type
      return if @form.has_evidence_of_benefit.nil?

      if @form.has_evidence_of_benefit == 'true'
        legal_aid_application.change_state_machine_type('PassportedStateMachine')
      else
        legal_aid_application.change_state_machine_type('NonPassportedStateMachine')
      end
    end

    def dwp_override
      @dwp_override ||= legal_aid_application.dwp_override
    end

    def form_params
      merge_with_model(dwp_override) do
        return {} unless params[:dwp_override]

        params.require(:dwp_override).permit(:has_evidence_of_benefit)
      end
    end
  end
end
