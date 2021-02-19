module LegalAidApplications
  class StudentFinanceForm
    include BaseForm

    form_for LegalAidApplication

    attr_accessor :student_finance

    validate :student_finance_presence

    private

    def student_finance_presence
      return if draft? || student_finance.present?

      errors.add(:student_finance, I18n.t('activemodel.errors.models.legal_aid_application.attributes.student_finance.blank'))
    end
  end
end
