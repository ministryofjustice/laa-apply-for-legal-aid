module Applicants
  class EmploymentIncomeForm < BaseEmploymentIncomeForm
    form_for Applicant

    attr_accessor :extra_employment_information, :extra_employment_information_details

  private

    def add_blank_error_for(attribute)
      errors.add(attribute, I18n.t("activemodel.errors.models.applicant.attributes.#{attribute}.blank"))
    end
  end
end
