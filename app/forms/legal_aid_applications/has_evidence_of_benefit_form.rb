module LegalAidApplications
  class HasEvidenceOfBenefitForm
    include BaseForm

    form_for DWPOverride

    attr_accessor :has_evidence_of_benefit

    validate :evidence_present

    private

    def passporting_benefit_error
      ".shared.forms.received_benefit_confirmation.form.providers.received_benefit_confirmations.#{model.passporting_benefit}"
    end

    def blank_error
      'activemodel.errors.models.dwp_override.attributes.has_evidence_of_benefit.blank'
    end

    def evidence_present
      return if has_evidence_of_benefit.present?

      errors.add(:has_evidence_of_benefit,
                 I18n.t(blank_error, passporting_benefit: I18n.t(passporting_benefit_error)))
    end
  end
end
