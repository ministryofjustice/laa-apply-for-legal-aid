module LegalAidApplications
  class NoEmploymentIncomeForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :full_employment_details

    validate :full_employment_details_presence

  private

    def full_employment_details_presence
      return if draft?

      errors.add(:full_employment_details, I18n.t("activemodel.errors.models.legal_aid_application.attributes.full_employment_details.blank")) if full_employment_details.blank?
    end
  end
end
