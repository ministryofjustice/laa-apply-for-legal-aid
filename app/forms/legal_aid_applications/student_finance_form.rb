module LegalAidApplications
  class StudentFinanceForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :student_finance, :income_type, :frequency

    validate :student_finance_presence

    def student_finance_presence
      return if draft? || student_finance.present?

      errors.add(:student_finance, I18n.t("activemodel.errors.models.legal_aid_application.attributes.student_finance.blank"))
    end

    def exclude_from_model
      [:student_finance]
    end
  end
end
