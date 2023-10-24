module Partners
  class UnexpectedEmploymentIncomeForm < BaseForm
    form_for Partner

    attr_accessor :extra_employment_information_details

    validate :extra_employment_information_details_presence

  private

    def extra_employment_information_details_presence
      return if draft?

      add_blank_error_for :extra_employment_information_details if extra_employment_information_details.blank?
    end

    def add_blank_error_for(attribute)
      errors.add(attribute, I18n.t("activemodel.errors.models.partner.attributes.#{attribute}.blank"))
    end
  end
end
