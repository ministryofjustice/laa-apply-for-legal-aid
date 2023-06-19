module Applicants
  class EmployedForm < BaseEmployedForm
    form_for Applicant

  private

    def error_message_for_none_selected
      I18n.t("activemodel.errors.models.applicant.attributes.base.none_selected")
    end
  end
end
