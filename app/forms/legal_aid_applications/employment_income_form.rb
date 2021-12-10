module LegalAidApplications
  class EmploymentIncomeForm < BaseForm
    form_for LegalAidApplication

    attr_accessor :extra_employment_information, :employment_information_details

    before_validation :clear_employment_info_details

    validate :extra_employment_information_presence
    validate :employment_information_details_presence

    private

    def extra_employment_information_presence
      return if draft? || extra_employment_information.present?

      add_blank_error_for :extra_employment_information
    end

    def employment_information_details_presence
      return if draft? || extra_employment_information.to_s != 'true'

      add_blank_error_for :employment_information_details if employment_information_details.blank?
    end

    def add_blank_error_for(attribute)
      errors.add(attribute, I18n.t("activemodel.errors.models.legal_aid_application.attributes.#{attribute}.blank"))
    end

    def clear_employment_info_details
      employment_information_details&.clear if extra_employment_information.to_s == 'false'
    end
  end
end
