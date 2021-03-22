module Providers
  class HasEvidenceOfBenefitsController < ProviderBaseController
    def show
      @form = LegalAidApplications::HasEvidenceOfBenefitForm.new(model: dwp_override)
      passporting_benefit
    end

    def update
      return continue_or_draft if draft_selected?

      @form = LegalAidApplications::HasEvidenceOfBenefitForm.new(form_params)

      passporting_benefit

      if @form.save
        details_checked! unless details_checked?
        go_forward(evidence_of_benefit?)
      else
        render :show
      end
    end

    private

    def passporting_benefit_translation
      I18n.t(".shared.forms.received_benefit_confirmation.form.providers.received_benefit_confirmations.#{dwp_override.passporting_benefit}")
    end

    def evidence_of_benefit?
      form_params[:has_evidence_of_benefit] == 'true'
    end

    def passporting_benefit
      @passporting_benefit ||= passporting_benefit_translation
    end

    def details_checked!
      legal_aid_application.applicant_details_checked!
    end

    def details_checked?
      legal_aid_application.applicant_details_checked?
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
