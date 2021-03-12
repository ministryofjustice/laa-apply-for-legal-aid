module LegalAidApplications
  class HasEvidenceOfBenefitForm
    include BaseForm

    form_for DWPOverride

    attr_accessor :has_evidence_of_benefit

    validate :evidence_present

    private

    def evidence_present
      return if draft? || has_evidence_of_benefit.present?

      errors.add(:has_evidence_of_benefit,
                 I18n.t('activemodel.errors.models.dwp_override.attributes.has_evidence_of_benefit.blank', passporting_benefit: model.passporting_benefit))
    end
  end
end
